import { Router } from "express";
import { CreateUser, GetRegister, DeleteUser } from "../Controllers/Register";
import { CreateFullScore, GetFullScore, DeleteFullScore } from "../Controllers/Scoreboard";

const router = Router();

router.post("/createuser", CreateUser);
router.get("/getusers", GetRegister);
router.post("/createscore", CreateFullScore);
router.get("/getfullscore", GetFullScore);
router.delete("/deletefullscore", DeleteFullScore);
router.delete("/deleteuser", DeleteUser);

export { router };
