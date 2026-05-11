const express = require("express");
const cors = require("cors");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const db = require("./db");
const { GoogleGenerativeAI } = require("@google/generative-ai");
require("dotenv").config();

const app = express();
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json({ limit: '50mb' }));

const JWT_SECRET = process.env.JWT_SECRET;

// ============================================================
// HELPERS
// ============================================================
const dbQuery = (sql, params) =>
  new Promise((resolve, reject) =>
    db.query(sql, params, (err, results) => (err ? reject(err) : resolve(results)))
  );

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];
  if (!token) return res.status(401).json({ message: "Token não fornecido." });
  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ message: "Token inválido ou expirado." });
    req.user = user;
    next();
  });
};

// ============================================================
// AUTH
// ============================================================
app.post("/register", async (req, res) => {
  const { nome, cpf, email, password } = req.body;
  if (!nome || !cpf || !email || !password)
    return res.status(400).json({ message: "Todos os campos são obrigatórios!" });
  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    db.query(
      "INSERT INTO user (nome, cpf, email, hash_password) VALUES (?, ?, ?, ?)",
      [nome, cpf, email, hashedPassword],
      (err) => {
        if (err) {
          if (err.code === "ER_DUP_ENTRY")
            return res.status(409).json({ message: "Este e-mail já está cadastrado." });
          return res.status(500).json({ message: "Erro ao registrar usuário no banco." });
        }
        res.status(201).json({ message: "Usuário registrado com sucesso!" });
      }
    );
  } catch {
    res.status(500).json({ message: "Erro interno do servidor." });
  }
});

app.post("/login", (req, res) => {
  const { email, password } = req.body;
  if (!email || !password)
    return res.status(400).json({ message: "E-mail e senha são obrigatórios." });
  db.query("SELECT * FROM user WHERE email = ?", [email], async (err, results) => {
    if (err) return res.status(500).json({ message: "Erro interno do servidor." });
    if (results.length === 0)
      return res.status(401).json({ message: "E-mail ou senha inválidos." });
    const user = results[0];
    const isMatch = await bcrypt.compare(password, user.hash_password);
    if (!isMatch)
      return res.status(401).json({ message: "E-mail ou senha inválidos." });
    const token = jwt.sign(
      { id: user.id, email: user.email, nome: user.nome },
      JWT_SECRET,
      { expiresIn: "8h" }
    );
    res.status(200).json({
      message: "Login bem-sucedido!",
      token,
      user: { id: user.id, nome: user.nome, email: user.email },
    });
  });
});

// ============================================================
// CRUD — USUÁRIO
// ============================================================
app.get("/profile", authenticateToken, async (req, res) => {
  try {
    const rows = await dbQuery("SELECT id, nome, cpf, email FROM user WHERE id = ?", [req.user.id]);
    if (rows.length === 0) return res.status(404).json({ message: "Usuário não encontrado." });
    res.status(200).json(rows[0]);
  } catch { res.status(500).json({ message: "Erro ao buscar perfil." }); }
});

app.put("/profile", authenticateToken, async (req, res) => {
  const { nome, cpf, email } = req.body;
  if (!nome && !cpf && !email)
    return res.status(400).json({ message: "Informe ao menos um campo." });
  try {
    const fields = [], values = [];
    if (nome) { fields.push("nome = ?"); values.push(nome); }
    if (cpf)  { fields.push("cpf = ?");  values.push(cpf);  }
    if (email){ fields.push("email = ?"); values.push(email);}
    values.push(req.user.id);
    await dbQuery(`UPDATE user SET ${fields.join(", ")} WHERE id = ?`, values);
    res.status(200).json({ message: "Perfil atualizado!" });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

app.put("/profile/password", authenticateToken, async (req, res) => {
  const { currentPassword, newPassword } = req.body;
  if (!currentPassword || !newPassword)
    return res.status(400).json({ message: "Informe a senha atual e a nova." });
  try {
    const rows = await dbQuery("SELECT hash_password FROM user WHERE id = ?", [req.user.id]);
    const isMatch = await bcrypt.compare(currentPassword, rows[0].hash_password);
    if (!isMatch) return res.status(401).json({ message: "Senha atual incorreta." });
    const hashed = await bcrypt.hash(newPassword, 10);
    await dbQuery("UPDATE user SET hash_password = ? WHERE id = ?", [hashed, req.user.id]);
    res.status(200).json({ message: "Senha alterada!" });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

app.delete("/profile", authenticateToken, async (req, res) => {
  try {
    await dbQuery("DELETE FROM user WHERE id = ?", [req.user.id]);
    res.status(200).json({ message: "Conta deletada." });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// ============================================================
// CRUD — PLANO ALIMENTAR
// ============================================================
app.get("/api/my-plan", authenticateToken, async (req, res) => {
  const userId = req.user.id;
  try {
    const plans = await dbQuery(
      "SELECT id, nome, data_criacao FROM plano_alimentar WHERE usuario_id = ? AND ativo = 'Sim' LIMIT 1",
      [userId]
    );
    if (plans.length === 0)
      return res.status(200).json({ success: true, hasPlan: false });

    const plan = plans[0];
    const today = new Date().toISOString().split("T")[0];

    const rows = await dbQuery(
      `SELECT r.id AS refeicao_id, r.nome AS refeicao_nome,
        TIME_FORMAT(r.horario_previsto, '%H:%i') AS horario,
        a.id AS alimento_id, a.Nome AS alimento_nome,
        a.porcao_g, a.calorias, a.proteinas, a.carbos, a.gorduras,
        i.quantidade_g, i.id AS item_id
      FROM refeicoes_base r
      LEFT JOIN itens_refeicao_base i ON i.refeicao_id = r.id
      LEFT JOIN alimentos a ON a.id = i.alimento_id
      WHERE r.plano_id = ?
      ORDER BY r.horario_previsto, r.id`,
      [plan.id]
    );

    // Logs do dia para aplicar trocas
    const logs = await dbQuery(
      `SELECT ld.*, a1.Nome AS alimento_original_nome,
        a2.Nome AS alimento_novo_nome, a2.calorias AS alimento_novo_calorias,
        a2.proteinas AS alimento_novo_proteinas, a2.carbos AS alimento_novo_carbos,
        a2.gorduras AS alimento_novo_gorduras
      FROM itens_diario ld
      LEFT JOIN alimentos a1 ON a1.id = ld.alimento_id
      LEFT JOIN alimentos a2 ON a2.id = ld.alimento_novo_id
      WHERE ld.diario_id IN (
        SELECT id FROM logs_diarios WHERE usuario_id = ? AND data = ?
      )`,
      [userId, today]
    );

    const trocasMap = {};
    for (const log of logs) {
      if (log.tipo === 'consumido' && log.alimento_novo_id)
        trocasMap[log.alimento_id] = log;
    }

    const refeicaoMap = {};
    for (const row of rows) {
      if (!refeicaoMap[row.refeicao_id]) {
        refeicaoMap[row.refeicao_id] = {
          id: row.refeicao_id, nome: row.refeicao_nome,
          horario: row.horario || "", alimentos: [],
        };
      }
      if (row.alimento_id) {
        const troca = trocasMap[row.alimento_id];
        refeicaoMap[row.refeicao_id].alimentos.push({
          id: row.alimento_id, item_id: row.item_id,
          nome: troca ? `${troca.alimento_novo_nome} (troca)` : row.alimento_nome,
          quantidade_g: parseFloat(row.quantidade_g) || 0,
          calorias: troca ? troca.alimento_novo_calorias : (row.calorias || "0"),
          proteinas: troca ? troca.alimento_novo_proteinas : (row.proteinas || "0"),
          carbos: troca ? troca.alimento_novo_carbos : (row.carbos || "0"),
          gorduras: troca ? troca.alimento_novo_gorduras : (row.gorduras || "0"),
          foi_trocado: !!troca,
          alimento_novo_id: troca?.alimento_novo_id ?? null,
        });
      }
    }

    const macro = await dbQuery(
      "SELECT calorias, proteinas, carbos, gordura FROM max_micronutrientes WHERE id_user = ? LIMIT 1",
      [userId]
    );

    // Recupera dados biométricos da tabela dedicada
    let planMeta = null;
    try {
      const metaRows = await dbQuery(
        "SELECT goal, weight, height, age, gender, activity_level AS activityLevel, water_goal AS waterGoal FROM user_plan_meta WHERE user_id = ? LIMIT 1",
        [userId]
      );
      if (metaRows.length > 0) planMeta = metaRows[0];
    } catch (_) {}

    res.status(200).json({
      success: true, hasPlan: true,
      plan: { id: plan.id, nome: plan.nome, data_criacao: plan.data_criacao, refeicoes: Object.values(refeicaoMap) },
      max_micronutrientes: macro[0] || null,
      plan_meta: planMeta,
    });
  } catch (error) {
    console.error("❌ [DB] Erro ao buscar plano:", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
});

app.put("/api/plan/:planId", authenticateToken, async (req, res) => {
  const { nome } = req.body;
  if (!nome) return res.status(400).json({ message: "Nome é obrigatório." });
  try {
    await dbQuery("UPDATE plano_alimentar SET nome = ? WHERE id = ? AND usuario_id = ?",
      [nome, req.params.planId, req.user.id]);
    res.status(200).json({ message: "Plano atualizado!" });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

app.delete("/api/plan/:planId", authenticateToken, async (req, res) => {
  try {
    await dbQuery("UPDATE plano_alimentar SET ativo = 'Nao' WHERE id = ? AND usuario_id = ?",
      [req.params.planId, req.user.id]);
    res.status(200).json({ message: "Plano removido!" });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// ============================================================
// CRUD — REFEIÇÕES BASE
// ============================================================
app.post("/api/refeicao", authenticateToken, async (req, res) => {
  const { plano_id, nome, horario_previsto } = req.body;
  if (!plano_id || !nome) return res.status(400).json({ message: "plano_id e nome são obrigatórios." });
  try {
    const result = await dbQuery(
      "INSERT INTO refeicoes_base (plano_id, nome, horario_previsto) VALUES (?, ?, ?)",
      [plano_id, nome, horario_previsto || "00:00:00"]
    );
    res.status(201).json({ message: "Refeição criada!", id: result.insertId });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

app.put("/api/refeicao/:id", authenticateToken, async (req, res) => {
  const { nome, horario_previsto } = req.body;
  try {
    await dbQuery("UPDATE refeicoes_base SET nome = ?, horario_previsto = ? WHERE id = ?",
      [nome, horario_previsto, req.params.id]);
    res.status(200).json({ message: "Refeição atualizada!" });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

app.delete("/api/refeicao/:id", authenticateToken, async (req, res) => {
  try {
    await dbQuery("DELETE FROM itens_refeicao_base WHERE refeicao_id = ?", [req.params.id]);
    await dbQuery("DELETE FROM refeicoes_base WHERE id = ?", [req.params.id]);
    res.status(200).json({ message: "Refeição deletada!" });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// ============================================================
// CRUD — ITENS DA REFEIÇÃO
// ============================================================
app.post("/api/item-refeicao", authenticateToken, async (req, res) => {
  const { refeicao_id, alimento_id, quantidade_g } = req.body;
  if (!refeicao_id || !alimento_id)
    return res.status(400).json({ message: "refeicao_id e alimento_id são obrigatórios." });
  try {
    const result = await dbQuery(
      "INSERT INTO itens_refeicao_base (refeicao_id, alimento_id, quantidade_g) VALUES (?, ?, ?)",
      [refeicao_id, alimento_id, quantidade_g || 100]
    );
    res.status(201).json({ message: "Alimento adicionado!", id: result.insertId });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

app.put("/api/item-refeicao/:id", authenticateToken, async (req, res) => {
  try {
    await dbQuery("UPDATE itens_refeicao_base SET quantidade_g = ? WHERE id = ?",
      [req.body.quantidade_g, req.params.id]);
    res.status(200).json({ message: "Quantidade atualizada!" });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

app.delete("/api/item-refeicao/:id", authenticateToken, async (req, res) => {
  try {
    await dbQuery("DELETE FROM itens_refeicao_base WHERE id = ?", [req.params.id]);
    res.status(200).json({ message: "Alimento removido!" });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// ============================================================
// CRUD — ALIMENTOS
// ============================================================
app.get("/api/alimentos", authenticateToken, async (req, res) => {
  try {
    const rows = await dbQuery("SELECT * FROM alimentos ORDER BY Nome ASC", []);
    res.status(200).json({ success: true, alimentos: rows });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

app.post("/api/alimento", authenticateToken, async (req, res) => {
  const { Nome, porcao_g, calorias, proteinas, carbos, gorduras } = req.body;
  if (!Nome) return res.status(400).json({ message: "Nome é obrigatório." });
  try {
    const result = await dbQuery(
      "INSERT INTO alimentos (Nome, porcao_g, calorias, proteinas, carbos, gorduras) VALUES (?, ?, ?, ?, ?, ?)",
      [Nome, porcao_g || "100", calorias || "0", proteinas || "0", carbos || "0", gorduras || "0"]
    );
    res.status(201).json({ message: "Alimento criado!", id: result.insertId });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

app.put("/api/alimento/:id", authenticateToken, async (req, res) => {
  const { Nome, porcao_g, calorias, proteinas, carbos, gorduras } = req.body;
  try {
    await dbQuery(
      "UPDATE alimentos SET Nome=?, porcao_g=?, calorias=?, proteinas=?, carbos=?, gorduras=? WHERE id=?",
      [Nome, porcao_g, calorias, proteinas, carbos, gorduras, req.params.id]
    );
    res.status(200).json({ message: "Alimento atualizado!" });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

app.delete("/api/alimento/:id", authenticateToken, async (req, res) => {
  try {
    await dbQuery("DELETE FROM alimentos WHERE id = ?", [req.params.id]);
    res.status(200).json({ message: "Alimento deletado!" });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// ============================================================
// CRUD — LOGS DIÁRIOS
// ============================================================
app.get("/api/logs-hoje", authenticateToken, async (req, res) => {
  const today = new Date().toISOString().split("T")[0];
  try {
    const diario = await dbQuery(
      "SELECT * FROM logs_diarios WHERE usuario_id = ? AND data = ? LIMIT 1",
      [req.user.id, today]
    );
    if (diario.length === 0)
      return res.status(200).json({ success: true, log: null, itens: [] });
    const itens = await dbQuery(
      `SELECT id.*, a.Nome, a.calorias, a.proteinas, a.carbos, a.gorduras
       FROM itens_diario id LEFT JOIN alimentos a ON a.id = id.alimento_id
       WHERE id.diario_id = ?`,
      [diario[0].id]
    );
    res.status(200).json({ success: true, log: diario[0], itens });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

app.post("/api/log-refeicao", authenticateToken, async (req, res) => {
  const userId = req.user.id;
  const { alimento_id, quantidade_g, tipo, refeicao_referencia, alimento_novo_id } = req.body;
  const today = new Date().toISOString().split("T")[0];
  if (!alimento_id || !tipo)
    return res.status(400).json({ message: "alimento_id e tipo são obrigatórios." });
  try {
    let diario = await dbQuery(
      "SELECT id FROM logs_diarios WHERE usuario_id = ? AND data = ?",
      [userId, today]
    );
    let diarioId;
    if (diario.length === 0) {
      const result = await dbQuery(
        "INSERT INTO logs_diarios (usuario_id, data, status) VALUES (?, ?, 'no_plano')",
        [userId, today]
      );
      diarioId = result.insertId;
    } else {
      diarioId = diario[0].id;
    }

    await dbQuery(
      "INSERT INTO itens_diario (diario_id, alimento_id, quantidade_g, tipo, refeicao_referencia, alimento_novo_id) VALUES (?, ?, ?, ?, ?, ?)",
      [diarioId, alimento_id, quantidade_g || 100, tipo, refeicao_referencia || null, alimento_novo_id || null]
    );

    if (tipo === 'fuga') {
      await dbQuery("UPDATE logs_diarios SET status = 'fuga_compensada' WHERE id = ?", [diarioId]);
    }

    res.status(201).json({ message: "Registro salvo!" });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

app.delete("/api/log-item/:id", authenticateToken, async (req, res) => {
  try {
    await dbQuery("DELETE FROM itens_diario WHERE id = ?", [req.params.id]);
    res.status(200).json({ message: "Item removido!" });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// ============================================================
// IA — FOOD SWAP (mantido do seu amigo)
// ============================================================
app.post("/api/food-swap", authenticateToken, async (req, res) => {
  const { foodName, goal, allergies, preferences } = req.body;
  if (!foodName)
    return res.status(400).json({ success: false, message: "foodName é obrigatório." });

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    return res.status(200).json({
      success: true,
      swaps: [
        { original: foodName, suggestion: "Batata doce", reason: "Menor índice glicêmico", ratio: "100g → 120g", calories: 86 },
        { original: foodName, suggestion: "Quinoa", reason: "Proteína completa", ratio: "100g → 80g", calories: 120 },
        { original: foodName, suggestion: "Mandioca cozida", reason: "Opção regional nutritiva", ratio: "100g → 130g", calories: 125 },
      ],
    });
  }

  try {
    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });
    const prompt = `Nutricionista: sugira 3 substitutos para "${foodName}". Objetivo: ${goal || "não informado"}. Alergias: ${allergies?.join(", ") || "nenhuma"}. Preferências: ${preferences?.join(", ") || "nenhuma"}.
Retorne APENAS JSON: {"swaps":[{"suggestion":"","reason":"","ratio":"100g → Xg","calories":0}]}`;
    const result = await model.generateContent(prompt);
    const text = result.response.text().trim();
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (!jsonMatch) throw new Error("Formato inválido");
    const parsed = JSON.parse(jsonMatch[0]);
    res.status(200).json({ success: true, swaps: parsed.swaps.map(s => ({ ...s, original: foodName })) });
  } catch (error) {
    res.status(500).json({ success: false, message: "Erro na IA: " + error.message });
  }
});

// ============================================================
// IA — FUGA DA DIETA
// ============================================================
app.post("/api/diet-escape", authenticateToken, async (req, res) => {
  const { foodDescription, caloriesConsumed, caloriesGoal } = req.body;
  if (!foodDescription)
    return res.status(400).json({ success: false, message: "foodDescription é obrigatório." });

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    return res.status(200).json({
      success: true,
      analysis: {
        message: `Fuga: "${foodDescription}". Vamos ajustar!`,
        adjustments: [
          { type: "reduce", food: "Arroz do jantar", amount: "-80g" },
          { type: "reduce", food: "Pão do lanche", amount: "-1 fatia" },
          { type: "add", food: "Caminhada leve", amount: "+20 minutos" },
        ],
        suggestion: "Frango grelhado com salada no jantar",
        motivation: "Uma refeição não define sua jornada. Continue firme!",
      },
    });
  }

  try {
    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });
    const prompt = `Nutricionista: usuário comeu "${foodDescription}" fora do plano. Meta: ${caloriesGoal} kcal. Consumido: ${caloriesConsumed} kcal.
Sugira ajustes e uma alternativa saudável. Retorne APENAS JSON:
{"message":"","adjustments":[{"type":"reduce|add","food":"","amount":""}],"suggestion":"alimento saudável alternativo","motivation":""}`;
    const result = await model.generateContent(prompt);
    const text = result.response.text().trim();
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (!jsonMatch) throw new Error("Formato inválido");
    res.status(200).json({ success: true, analysis: JSON.parse(jsonMatch[0]) });
  } catch (error) {
    res.status(500).json({ success: false, message: "Erro na IA: " + error.message });
  }
});

// ============================================================
// SCAN (mantido do seu amigo)
// ============================================================
app.post("/api/scan-plan", authenticateToken, async (req, res) => {
  const { fileBase64, mimeType } = req.body;
  if (!fileBase64 || !mimeType)
    return res.status(400).json({ success: false, message: "fileBase64 e mimeType são obrigatórios." });
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey)
    return res.status(400).json({ success: false, message: "GEMINI_API_KEY não configurada." });
  try {
    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });
    const prompt = `Nutricionista: analise este plano alimentar e extraia TODAS as informações.
Retorne APENAS JSON válido:
{"plano":{"nome":""},"max_micronutrientes":{"calorias":0,"proteinas":0,"carbos":0,"gordura":0},"refeicoes":[{"nome":"","horario_previsto":"HH:MM:SS","alimentos":[{"Nome":"","porcao_g":"100","calorias":"0","proteinas":"0","carbos":"0","gorduras":"0","quantidade_g":100}]}]}`;
    const result = await model.generateContent([{ inlineData: { data: fileBase64, mimeType } }, prompt]);
    const text = result.response.text().trim();
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (!jsonMatch) throw new Error("Formato inválido.");
    res.status(200).json({ success: true, data: JSON.parse(jsonMatch[0]) });
  } catch (error) {
    res.status(500).json({ success: false, message: "Erro ao analisar: " + error.message });
  }
});

// POST /api/save-plan — salva plano criado manualmente pelo usuário
app.post("/api/save-plan", authenticateToken, async (req, res) => {
  const userId = req.user.id;
  const {
    goal, weight, height, age, gender, activityLevel,
    waterGoal, caloriesGoal, proteinGoal, carbsGoal, fatGoal,
  } = req.body;
  try {
    // Cria tabela de metadados se não existir
    await dbQuery(`
      CREATE TABLE IF NOT EXISTS user_plan_meta (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL UNIQUE,
        goal VARCHAR(100),
        weight DECIMAL(6,2),
        height DECIMAL(6,2),
        age INT,
        gender VARCHAR(20),
        activity_level VARCHAR(50),
        water_goal DECIMAL(5,2),
        CONSTRAINT fk_plan_meta_user FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE
      )
    `, []);

    // Desativa plano anterior
    await dbQuery(
      "UPDATE plano_alimentar SET ativo = 'Nao' WHERE usuario_id = ? AND ativo = 'Sim'",
      [userId]
    );

    const today = new Date().toISOString().split("T")[0];
    const nomePlano = `Plano ${goal}`;
    const planResult = await dbQuery(
      "INSERT INTO plano_alimentar (usuario_id, nome, ativo, data_criacao) VALUES (?, ?, 'Sim', ?)",
      [userId, nomePlano, today]
    );
    const planId = planResult.insertId;

    // Salva metas de macros
    await dbQuery("DELETE FROM max_micronutrientes WHERE id_user = ?", [userId]);
    await dbQuery(
      "INSERT INTO max_micronutrientes (calorias, proteinas, carbos, gordura, id_user) VALUES (?, ?, ?, ?, ?)",
      [caloriesGoal || 0, proteinGoal || 0, carbsGoal || 0, fatGoal || 0, userId]
    );

    // Salva dados biométricos na tabela dedicada
    await dbQuery(`
      INSERT INTO user_plan_meta (user_id, goal, weight, height, age, gender, activity_level, water_goal)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE
        goal = VALUES(goal),
        weight = VALUES(weight),
        height = VALUES(height),
        age = VALUES(age),
        gender = VALUES(gender),
        activity_level = VALUES(activity_level),
        water_goal = VALUES(water_goal)
    `, [userId, goal, weight, height, age, gender, activityLevel, waterGoal]);

    console.log(`✅ Plano manual #${planId} salvo para usuário ${userId}`);
    res.status(201).json({ success: true, planId });
  } catch (error) {
    console.error("❌ Erro ao salvar plano:", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
});

app.post("/api/save-scanned-plan", authenticateToken, async (req, res) => {
  const { data } = req.body;
  const userId = req.user.id;
  if (!data || !data.plano || !Array.isArray(data.refeicoes))
    return res.status(400).json({ success: false, message: "Dados inválidos." });
  try {
    await dbQuery("UPDATE plano_alimentar SET ativo = 'Nao' WHERE usuario_id = ? AND ativo = 'Sim'", [userId]);
    const today = new Date().toISOString().split("T")[0];
    const planResult = await dbQuery(
      "INSERT INTO plano_alimentar (usuario_id, nome, ativo, data_criacao) VALUES (?, ?, 'Sim', ?)",
      [userId, data.plano.nome || "Plano Alimentar Digitalizado", today]
    );
    const planId = planResult.insertId;
    if (data.max_micronutrientes) {
      const mm = data.max_micronutrientes;
      await dbQuery("DELETE FROM max_micronutrientes WHERE id_user = ?", [userId]);
      await dbQuery(
        "INSERT INTO max_micronutrientes (calorias, proteinas, carbos, gordura, id_user) VALUES (?, ?, ?, ?, ?)",
        [mm.calorias || 0, mm.proteinas || 0, mm.carbos || 0, mm.gordura || 0, userId]
      );
    }
    for (const refeicao of data.refeicoes) {
      const refResult = await dbQuery(
        "INSERT INTO refeicoes_base (plano_id, nome, horario_previsto) VALUES (?, ?, ?)",
        [planId, refeicao.nome || "Refeição", refeicao.horario_previsto || "00:00:00"]
      );
      const refeicaoId = refResult.insertId;
      for (const alimento of (refeicao.alimentos || [])) {
        const existing = await dbQuery("SELECT id FROM alimentos WHERE Nome = ?", [alimento.Nome]);
        let alimentoId = existing.length > 0 ? existing[0].id : null;
        if (!alimentoId) {
          const aResult = await dbQuery(
            "INSERT INTO alimentos (Nome, porcao_g, calorias, proteinas, carbos, gorduras) VALUES (?, ?, ?, ?, ?, ?)",
            [alimento.Nome, String(alimento.porcao_g || "100"), String(alimento.calorias || "0"),
             String(alimento.proteinas || "0"), String(alimento.carbos || "0"), String(alimento.gorduras || "0")]
          );
          alimentoId = aResult.insertId;
        }
        await dbQuery(
          "INSERT INTO itens_refeicao_base (refeicao_id, alimento_id, quantidade_g) VALUES (?, ?, ?)",
          [refeicaoId, alimentoId, parseFloat(alimento.quantidade_g) || 100]
        );
      }
    }
    console.log(`✅ Plano #${planId} salvo para usuário ${userId}.`);
    res.status(200).json({ success: true, planId });
  } catch (error) {
    console.error("❌ Erro ao salvar plano:", error.message);
    res.status(500).json({ success: false, message: "Erro ao salvar: " + error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ Servidor DietHub rodando em http://localhost:${PORT}`);
});
