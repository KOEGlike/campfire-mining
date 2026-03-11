import { Router } from "express";
import { CreateUser, GetRegister, DeleteUsers, DeleteOneUser } from "../Controllers/Register";
import { CreateFullScore, GetFullScore, DeleteFullScore } from "../Controllers/Scoreboard";

const router = Router();

router.post("/createuser", CreateUser);
router.get("/getusers", GetRegister);
router.post("/createscore", CreateFullScore);
router.get("/getfullscore", GetFullScore);
router.get("/deletefullscore", DeleteFullScore);
router.get("/deleteallusers", DeleteUsers);
router.get("/deleteoneuser", DeleteOneUser);

export { router };
