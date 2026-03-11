import { Response, Request, NextFunction } from "express";
import { serverdb } from "../db/db";
import { User, ScoreTable } from "./../db/schema";
import { eq } from "drizzle-orm";

export const CreateUser = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { name } = req.body;
    if (name) {
      const newUser = await serverdb.insert(User).values({ name }).returning();
      res.status(200).json({ message: "success", success: true, Data: newUser[0] });
    }
  } catch (error) {
    next(error);
  }
};

export const GetRegister = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const alluser = await serverdb.select().from(User);
    console.log(alluser)
    res.status(200).json({success:true,users:alluser})
  } catch (error) {
    next(error);
  }
};

export const DeleteUsers = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const deletedUsers = await serverdb.delete(User).returning();
    
    res.status(200).json({ 
      message: "All users deleted successfully", 
      success: true, 
      deletedCount: deletedUsers.length 
    });
  } catch (error) {
    next(error);
  }
};

export const DeleteOneUser = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { userId } = req.query;
    if (userId) {
      await serverdb.delete(ScoreTable).where(eq(ScoreTable.userId, Number(userId)));
      const deletedUser = await serverdb.delete(User).where(eq(User.id, Number(userId))).returning();
      
      if (deletedUser.length > 0) {
        res.status(200).json({ 
          message: "User deleted successfully", 
          success: true, 
          deletedUser: deletedUser[0] 
        });
      } else {
        res.status(404).json({ 
          message: "User not found", 
          success: false 
        });
      }
    } else {
      res.status(400).json({ 
        message: "User ID is required", 
        success: false 
      });
    }
  } catch (error) {
    next(error);
  }
}
