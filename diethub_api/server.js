const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const db = require("./db");
require("dotenv").config();

const app = express();
app.use(express.json());

const JWT_SECRET = process.env.JWT_SECRET;

// Rota de Registro de Usuário
app.post("/register", async (req, res) => {
  const { name, email, password, weight, height, objective } = req.body;

  try {
    const hashedPassword = await bcrypt.hash(password, 10); // Hash da senha para segurança
    const sql = "INSERT INTO users (name, email, password, weight, height, objective) VALUES (?, ?, ?, ?, ?, ?)";
    db.query(sql, [name, email, hashedPassword, weight, height, objective], (err, result) => {
      if (err) {
        if (err.code === "ER_DUP_ENTRY") {
          return res.status(409).json({ message: "Email já cadastrado." });
        }
        console.error("Erro ao registrar usuário: " + err.message);
        return res.status(500).json({ message: "Erro interno do servidor." });
      }
      res.status(201).json({ message: "Usuário registrado com sucesso!" });
    });
  } catch (error) {
    console.error("Erro ao hash da senha: " + error.message);
    res.status(500).json({ message: "Erro interno do servidor." });
  }
});

// Rota de Login de Usuário
app.post("/login", (req, res) => {
  const { email, password } = req.body;

  const sql = "SELECT * FROM users WHERE email = ?";
  db.query(sql, [email], async (err, results) => {
    if (err) {
      console.error("Erro ao buscar usuário: " + err.message);
      return res.status(500).json({ message: "Erro interno do servidor." });
    }
    if (results.length === 0) {
      return res.status(401).json({ message: "Email ou senha inválidos." });
    }

    const user = results[0];
    const isMatch = await bcrypt.compare(password, user.password); // Compara a senha fornecida com o hash salvo

    if (!isMatch) {
      return res.status(401).json({ message: "Email ou senha inválidos." });
    }

    const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: "1h" }); // Gera um token JWT
    res.status(200).json({ message: "Login bem-sucedido!", token });
  });
});

// Middleware de autenticação (exemplo para rotas protegidas)
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];

  if (token == null) return res.sendStatus(401); // Não autorizado se não houver token

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403); // Proibido se o token for inválido
    req.user = user;
    next(); // Continua para a próxima função (a rota protegida)
  });
};

// Exemplo de rota protegida
app.get("/profile", authenticateToken, (req, res) => {
  res.json({ message: `Bem-vindo, ${req.user.email}! Este é o seu perfil.` });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});