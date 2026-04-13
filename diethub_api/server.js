const express = require("express");
const cors = require("cors");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const db = require("./db");
require("dotenv").config();

const app = express();

// Aceita requisições de qualquer origem (necessário para o Flutter)
app.use(cors());
app.use(express.json());

const JWT_SECRET = process.env.JWT_SECRET;

// =============================================
// ROTA: POST /register
// =============================================
app.post("/register", async (req, res) => {
  const { nome, cpf, email, password } = req.body;

  if (!nome || !cpf || !email || !password) {
    return res.status(400).json({ message: "Todos os campos são obrigatórios!" });
  }

  try {
    const hashedPassword = await bcrypt.hash(password, 10);

    const sql = "INSERT INTO user (nome, cpf, email, hash_password) VALUES (?, ?, ?, ?)";

    db.query(sql, [nome, cpf, email, hashedPassword], (err, result) => {
      if (err) {
        // Erro de email duplicado (UNIQUE key)
        if (err.code === "ER_DUP_ENTRY") {
          return res.status(409).json({ message: "Este e-mail já está cadastrado." });
        }
        console.error("Erro ao registrar usuário:", err.message);
        return res.status(500).json({ message: "Erro ao registrar usuário no banco." });
      }
      res.status(201).json({ message: "Usuário registrado com sucesso!" });
    });
  } catch (error) {
    console.error("Erro ao processar registro:", error.message);
    res.status(500).json({ message: "Erro interno do servidor." });
  }
});

// =============================================
// ROTA: POST /login
// =============================================
app.post("/login", (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: "E-mail e senha são obrigatórios." });
  }

  const sql = "SELECT * FROM user WHERE email = ?";
  db.query(sql, [email], async (err, results) => {
    if (err) {
      console.error("Erro ao buscar usuário:", err.message);
      return res.status(500).json({ message: "Erro interno do servidor." });
    }
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
      user: {
        id: user.id,
        nome: user.nome,
        email: user.email,
      },
    });
  });
});

// =============================================
// MIDDLEWARE: Verifica JWT nas rotas protegidas
// =============================================
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

// =============================================
// ROTA: GET /profile (protegida)
// =============================================
app.get("/profile", authenticateToken, (req, res) => {
  const sql = "SELECT id, nome, cpf, email FROM user WHERE id = ?";
  db.query(sql, [req.user.id], (err, results) => {
    if (err) {
      return res.status(500).json({ message: "Erro ao buscar perfil." });
    }
    if (results.length === 0) {
      return res.status(404).json({ message: "Usuário não encontrado." });
    }
    res.status(200).json(results[0]);
  });
});

// =============================================
// START
// =============================================
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ Servidor DietHub rodando em http://localhost:${PORT}`);
});
