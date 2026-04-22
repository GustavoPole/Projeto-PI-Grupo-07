const express = require("express");
const cors = require("cors");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const db = require("./db");
require("dotenv").config();

const app = express();
app.use(cors());
app.use(express.json());

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

// ============================================================
// ROTAS DE IA — PREPARADAS PARA IMPLEMENTAÇÃO
// ============================================================
// Para implementar:
// 1. Escolha: Gemini ou OpenAI
// 2. Instale o SDK:
//    Gemini:  npm install @google/generative-ai
//    OpenAI:  npm install openai
// 3. Adicione no .env:
//    GEMINI_API_KEY=sua_chave_aqui
//    OPENAI_API_KEY=sua_chave_aqui
// 4. Descomente o código de cada rota e implemente
// ============================================================

app.post("/api/generate-plan", authenticateToken, async (req, res) => {
  const { goal, weight, height, age, gender, activityLevel, waterGoal, allergies, preferences, pathologies } = req.body;

  // ---- IMPLEMENTAR A IA AQUI ----
  // Exemplo com Gemini:
  //
  // const { GoogleGenerativeAI } = require("@google/generative-ai");
  // const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
  // const model = genAI.getGenerativeModel({ model: "gemini-pro" });
  // const prompt = `Crie um plano alimentar para: objetivo ${goal}, peso ${weight}kg,
  //   altura ${height}cm, idade ${age}, gênero ${gender}, atividade ${activityLevel},
  //   alergias: ${allergies?.join(", ")}, preferências: ${preferences?.join(", ")},
  //   patologias: ${pathologies?.join(", ")}. Retorne JSON com refeições e macros.`;
  // const result = await model.generateContent(prompt);
  // return res.status(200).json({ success: true, plan: JSON.parse(result.response.text()) });
  // ---- FIM DA IMPLEMENTAÇÃO ----

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

  // ---- IMPLEMENTAR A IA AQUI ----
  // const prompt = `O usuário comeu "${foodDescription}" fora do plano.
  //   Meta: ${caloriesGoal} kcal. Consumido: ${caloriesConsumed} kcal.
  //   Sugira ajustes motivadores. Retorne JSON com ajustes e mensagem.`;
  // ---- FIM DA IMPLEMENTAÇÃO ----

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

  // ---- IMPLEMENTAR A IA AQUI ----
  // const prompt = `Sugira 3 substitutos para "${foodName}".
  //   Objetivo: ${goal}. Alergias: ${allergies?.join(", ")}.
  //   Preferências: ${preferences?.join(", ")}. Retorne JSON.`;
  // ---- FIM DA IMPLEMENTAÇÃO ----

  console.log("🤖 [IA] /api/food-swap chamada — IA não implementada ainda.");
  res.status(200).json({
    success: true,
    swaps: [
      { original: foodName, suggestion: "Batata doce", reason: "Menor índice glicêmico", ratio: "100g → 120g" },
      { original: foodName, suggestion: "Quinoa", reason: "Proteína completa", ratio: "100g → 80g" },
      { original: foodName, suggestion: "Mandioca cozida", reason: "Opção regional nutritiva", ratio: "100g → 130g" },
    ],
  });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ Servidor DietHub rodando em http://localhost:${PORT}`);
});
