const express = require("express");
const cors = require("cors");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const db = require("./db");
const { GoogleGenerativeAI } = require("@google/generative-ai");
require("dotenv").config();

const app = express();
app.use(cors());
app.use(express.json({ limit: '50mb' }));

const JWT_SECRET = process.env.JWT_SECRET;

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

app.post("/register", async (req, res) => {
  const { nome, cpf, email, password } = req.body;
  if (!nome || !cpf || !email || !password) {
    return res.status(400).json({ message: "Todos os campos são obrigatórios!" });
  }
  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const sql = "INSERT INTO user (nome, cpf, email, hash_password) VALUES (?, ?, ?, ?)";
    db.query(sql, [nome, cpf, email, hashedPassword], (err) => {
      if (err) {
        if (err.code === "ER_DUP_ENTRY") {
          return res.status(409).json({ message: "Este e-mail já está cadastrado." });
        }
        return res.status(500).json({ message: "Erro ao registrar usuário no banco." });
      }
      res.status(201).json({ message: "Usuário registrado com sucesso!" });
    });
  } catch (error) {
    res.status(500).json({ message: "Erro interno do servidor." });
  }
});

app.post("/login", (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ message: "E-mail e senha são obrigatórios." });
  }
  const sql = "SELECT * FROM user WHERE email = ?";
  db.query(sql, [email], async (err, results) => {
    if (err) return res.status(500).json({ message: "Erro interno do servidor." });
    if (results.length === 0) {
      return res.status(401).json({ message: "E-mail ou senha inválidos." });
    }
    const user = results[0];
    const isMatch = await bcrypt.compare(password, user.hash_password);
    if (!isMatch) {
      return res.status(401).json({ message: "E-mail ou senha inválidos." });
    }
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

app.get("/profile", authenticateToken, (req, res) => {
  const sql = "SELECT id, nome, cpf, email FROM user WHERE id = ?";
  db.query(sql, [req.user.id], (err, results) => {
    if (err) return res.status(500).json({ message: "Erro ao buscar perfil." });
    if (results.length === 0) return res.status(404).json({ message: "Usuário não encontrado." });
    res.status(200).json(results[0]);
  });
});

app.post("/api/generate-plan", authenticateToken, async (req, res) => {
  const { goal, weight, height, age, gender, activityLevel, waterGoal, allergies, preferences, pathologies } = req.body;

  console.log("🤖 [IA] /api/generate-plan chamada — IA não implementada ainda.");
  res.status(200).json({
    success: true,
    message: "IA não implementada ainda. Usando dados simulados.",
    plan: {
      summary: `Plano personalizado para: ${goal}`,
      meals: [
        { name: "Café da manhã", time: "07:00", calories: 420 },
        { name: "Lanche da manhã", time: "10:00", calories: 230 },
        { name: "Almoço", time: "12:30", calories: 520 },
        { name: "Lanche da tarde", time: "15:30", calories: 180 },
        { name: "Jantar", time: "19:00", calories: 380 },
      ],
    },
  });
});

app.post("/api/diet-escape", authenticateToken, async (req, res) => {
  const { foodDescription, caloriesConsumed, caloriesGoal } = req.body;

  console.log("🤖 [IA] /api/diet-escape chamada — IA não implementada ainda.");
  res.status(200).json({
    success: true,
    analysis: {
      message: `Fuga registrada: "${foodDescription}". Vamos ajustar!`,
      adjustments: [
        { type: "reduce", food: "Arroz do jantar", amount: "-80g" },
        { type: "reduce", food: "Pão do lanche", amount: "-1 fatia" },
        { type: "add", food: "Caminhada leve", amount: "+20 minutos" },
      ],
      motivation: "Uma refeição não define sua jornada. Continue firme!",
    },
  });
});

app.post("/api/food-swap", authenticateToken, async (req, res) => {
  const { foodName, goal, allergies, preferences } = req.body;

  if (!foodName) {
    return res.status(400).json({ success: false, message: "foodName é obrigatório." });
  }

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    console.warn("⚠️ GEMINI_API_KEY não configurada — retornando qualquer coisa para não quebrar o app.");
    return res.status(200).json({
      success: true,
      swaps: [
        { original: foodName, suggestion: "Batata doce", reason: "Menor índice glicêmico e mais fibras", ratio: "100g → 120g", calories: 86 },
        { original: foodName, suggestion: "Quinoa", reason: "Proteína completa e sem glúten", ratio: "100g → 80g", calories: 120 },
        { original: foodName, suggestion: "Mandioca cozida", reason: "Opção regional com bom valor nutricional", ratio: "100g → 130g", calories: 125 },
      ],
    });
  }

  try {
    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

    const allergyText = allergies?.length ? `Alergias do usuário: ${allergies.join(", ")}.` : "Sem alergias relatadas.";
    const prefText = preferences?.length ? `Preferências alimentares: ${preferences.join(", ")}.` : "";
    const goalText = goal ? `Objetivo nutricional: ${goal}.` : "";

    const prompt = `Você é um nutricionista especialista em alimentação saudável. Sugira exatamente 3 substitutos nutricionais para o alimento "${foodName}".
${goalText} ${allergyText} ${prefText}
Considere equivalência calórica e nutricional. Respeite as alergias.

Retorne APENAS um JSON válido, sem markdown, sem texto extra:
{
  "swaps": [
    {
      "suggestion": "Nome do alimento substituto",
      "reason": "Motivo nutricional objetivo em uma frase curta",
      "ratio": "100g → Xg",
      "calories": 0
    }
  ]
}`;

    const result = await model.generateContent(prompt);
    const text = result.response.text().trim();

    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (!jsonMatch) throw new Error("Resposta fora do formato esperado");

    const parsed = JSON.parse(jsonMatch[0]);
    const swaps = parsed.swaps.map((s) => ({ ...s, original: foodName }));

    console.log(`✅ [Gemini] Trocas geradas para "${foodName}": ${swaps.map(s => s.suggestion).join(", ")}`);
    res.status(200).json({ success: true, swaps });
  } catch (error) {
    console.error("❌ [Gemini] Erro ao gerar trocas:", error.message);
    res.status(500).json({ success: false, message: "Erro ao consultar a IA: " + error.message });
  }
});


// GET /api/my-plan — retorna o plano ativo do usuario com refeicões e alimentos
app.get("/api/my-plan", authenticateToken, async (req, res) => {
  const userId = req.user.id;
  try {
    const plans = await dbQuery(
      "SELECT id, nome, data_criacao FROM plano_alimentar WHERE usuario_id = ? AND ativo = 'Sim' LIMIT 1",
      [userId]
    );
    if (plans.length === 0) {
      return res.status(200).json({ success: true, hasPlan: false });
    }
    const plan = plans[0];

    const rows = await dbQuery(
      `SELECT
        r.id        AS refeicao_id,
        r.nome      AS refeicao_nome,
        TIME_FORMAT(r.horario_previsto, '%H:%i') AS horario,
        a.id        AS alimento_id,
        a.Nome      AS alimento_nome,
        a.porcao_g,
        a.calorias,
        a.proteinas,
        a.carbos,
        a.gorduras,
        i.quantidade_g
      FROM refeicoes_base r
      LEFT JOIN itens_refeicao_base i ON i.refeicao_id = r.id
      LEFT JOIN alimentos a ON a.id = i.alimento_id
      WHERE r.plano_id = ?
      ORDER BY r.horario_previsto, r.id`,
      [plan.id]
    );

    const refeicaoMap = {};
    for (const row of rows) {
      if (!refeicaoMap[row.refeicao_id]) {
        refeicaoMap[row.refeicao_id] = {
          id: row.refeicao_id,
          nome: row.refeicao_nome,
          horario: row.horario || "",
          alimentos: [],
        };
      }
      if (row.alimento_id) {
        refeicaoMap[row.refeicao_id].alimentos.push({
          id: row.alimento_id,
          nome: row.alimento_nome,
          quantidade_g: parseFloat(row.quantidade_g) || 0,
          calorias: row.calorias || "0",
          proteinas: row.proteinas || "0",
          carbos: row.carbos || "0",
          gorduras: row.gorduras || "0",
        });
      }
    }

    res.status(200).json({
      success: true,
      hasPlan: true,
      plan: {
        id: plan.id,
        nome: plan.nome,
        data_criacao: plan.data_criacao,
        refeicoes: Object.values(refeicaoMap),
      },
    });
  } catch (error) {
    console.error("❌ [DB] Erro ao buscar plano:", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
});

const dbQuery = (sql, params) =>
  new Promise((resolve, reject) =>
    db.query(sql, params, (err, results) => (err ? reject(err) : resolve(results)))
  );


// POST /api/scan-plan — envia imagem/PDF para o Gemini e retorna JSON
app.post("/api/scan-plan", authenticateToken, async (req, res) => {
  const { fileBase64, mimeType } = req.body;

  if (!fileBase64 || !mimeType) {
    return res.status(400).json({ success: false, message: "fileBase64 e mimeType são obrigatórios." });
  }

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    return res.status(400).json({ success: false, message: "GEMINI_API_KEY não configurada no servidor. Adicione a chave no arquivo .env." });
  }

  try {
    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

    const prompt = `Você é um nutricionista especialista. Analise este documento de plano alimentar e extraia TODAS as informações nutricionais presentes.

Retorne APENAS um JSON válido, sem markdown, sem blocos de código, sem texto extra. Use exatamente este formato:
{
  "plano": {
    "nome": "Nome do plano ou 'Plano Alimentar Digitalizado' se não houver nome"
  },
  "max_micronutrientes": {
    "calorias": 0,
    "proteinas": 0,
    "carbos": 0,
    "gordura": 0
  },
  "refeicoes": [
    {
      "nome": "Nome da refeição (ex: Café da manhã, Almoço)",
      "horario_previsto": "HH:MM:SS",
      "alimentos": [
        {
          "Nome": "Nome exato do alimento",
          "porcao_g": "100",
          "calorias": "0",
          "proteinas": "0",
          "carbos": "0",
          "gorduras": "0",
          "quantidade_g": 100
        }
      ]
    }
  ]
}

Regras:
- porcao_g, calorias, proteinas, carbos, gorduras devem ser strings numéricas
- quantidade_g deve ser number
- horario_previsto no formato HH:MM:SS (ex: "07:00:00")
- Se um valor não estiver no documento, estime com base em valores nutricionais típicos do alimento
- Extraia TODAS as refeições e TODOS os alimentos visíveis no documento`;

    const result = await model.generateContent([
      { inlineData: { data: fileBase64, mimeType } },
      prompt,
    ]);

    const text = result.response.text().trim();
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (!jsonMatch) throw new Error("A IA retornou uma resposta fora do formato esperado.");

    const data = JSON.parse(jsonMatch[0]);
    console.log(`✅ [Gemini Scan] Plano extraído: ${data.refeicoes?.length ?? 0} refeições.`);
    res.status(200).json({ success: true, data });
  } catch (error) {
    console.error("❌ [Gemini Scan] Erro:", error.message);
    res.status(500).json({ success: false, message: "Erro ao analisar o arquivo: " + error.message });
  }
});


// POST /api/save-scanned-plan — salva o plano da ia no banco
//ordem: plano_alimentar → refeicoes_base → alimentos → itens_refeicao_base → max_micronutrientes (revisar depois a estrutura do banco itens_diarios) 
app.post("/api/save-scanned-plan", authenticateToken, async (req, res) => {
  const { data } = req.body;
  const userId = req.user.id;

  if (!data || !data.plano || !Array.isArray(data.refeicoes)) {
    return res.status(400).json({ success: false, message: "Dados do plano inválidos ou incompletos." });
  }

  try {
    //desativa planos anteriores
    await dbQuery("UPDATE plano_alimentar SET ativo = 'Nao' WHERE usuario_id = ? AND ativo = 'Sim'", [userId]);

    // cria a dieta nova
    const today = new Date().toISOString().split("T")[0];
    const planResult = await dbQuery(
      "INSERT INTO plano_alimentar (usuario_id, nome, ativo, data_criacao) VALUES (?, ?, 'Sim', ?)",
      [userId, data.plano.nome || "Plano Alimentar Digitalizado", today]
    );
    const planId = planResult.insertId;

    // salva max_micronutrientes
    if (data.max_micronutrientes) {
      const mm = data.max_micronutrientes;
      await dbQuery("DELETE FROM max_micronutrientes WHERE id_user = ?", [userId]);
      await dbQuery(
        "INSERT INTO max_micronutrientes (calorias, proteinas, carbos, gordura, id_user) VALUES (?, ?, ?, ?, ?)",
        [mm.calorias || 0, mm.proteinas || 0, mm.carbos || 0, mm.gordura || 0, userId]
      );
    }

    // cria cada refeição e seus alimentos
    for (const refeicao of data.refeicoes) {
      const refResult = await dbQuery(
        "INSERT INTO refeicoes_base (plano_id, nome, horario_previsto) VALUES (?, ?, ?)",
        [planId, refeicao.nome || "Refeição", refeicao.horario_previsto || "00:00:00"]
      );
      const refeicaoId = refResult.insertId;

      for (const alimento of (refeicao.alimentos || [])) {
        // reutiliza alimento existente (noem igual) ou cria novo
        const existing = await dbQuery("SELECT id FROM alimentos WHERE Nome = ?", [alimento.Nome]);
        let alimentoId;

        if (existing.length > 0) {
          alimentoId = existing[0].id;
        } else {
          const aResult = await dbQuery(
            "INSERT INTO alimentos (Nome, porcao_g, calorias, proteinas, carbos, gorduras) VALUES (?, ?, ?, ?, ?, ?)",
            [
              alimento.Nome,
              String(alimento.porcao_g || "100"),
              String(alimento.calorias || "0"),
              String(alimento.proteinas || "0"),
              String(alimento.carbos || "0"),
              String(alimento.gorduras || "0"),
            ]
          );
          alimentoId = aResult.insertId;
        }

        await dbQuery(
          "INSERT INTO itens_refeicao_base (refeicao_id, alimento_id, quantidade_g) VALUES (?, ?, ?)",
          [refeicaoId, alimentoId, parseFloat(alimento.quantidade_g) || 100]
        );
      }
    }

    console.log(`✅ [DB] Plano #${planId} salvo para usuário ${userId}.`);
    res.status(200).json({ success: true, planId });
  } catch (error) {
    console.error("❌ [DB] Erro ao salvar plano:", error.message);
    res.status(500).json({ success: false, message: "Erro ao salvar no banco: " + error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ Servidor DietHub rodando em http://localhost:${PORT}`);
});
