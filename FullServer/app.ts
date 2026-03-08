import express from "express";
import cors from "cors";
import { errorHandler } from "./Middlewares/ErrorHandler";
import { router as allRoutes } from "./Routes/allroutes";

const app = express();

app.use(cors({
  origin: ["https://phgjaqmakdewq.ok.kimi.link" , "http://localhost:3000",
    "http://localhost:5173",
    "http://localhost:8060",
    "https://koeglike.itch.io/earth-escape",
    "http://127.0.0.1:5173",],
  credentials: true
}));

app.use(express.json());

app.use("/", allRoutes);

app.get("/test", (req, res) => {
  res.status(200).json({ message: "aaaa" });
});

app.use(errorHandler);
app.listen(5000, () => {
  console.log("server started on Port 5000");
});
