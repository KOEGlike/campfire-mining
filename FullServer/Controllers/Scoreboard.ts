import { Request, Response, NextFunction } from "express";
import { serverdb } from "../db/db";
import { ScoreTable, User } from "../db/schema";
import { eq } from "drizzle-orm";

const calculateScore = (
  timeinseconds: number,
  starcount: number,
  iscompleted: boolean,
): number => {
  const fullscore =
    timeinseconds * 10 + starcount * 500 + (iscompleted ? 1000 : 0);
  return fullscore;
};

export const CreateFullScore = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { userId, time, starcount, iscompleted } = req.body;
    if (userId !== undefined && time !== undefined && starcount !== undefined) {
      const userData = await serverdb
        .select()
        .from(User)
        .where(eq(User.id, userId));

      if (userData.length === 0) {
        res.status(404).json({ message: "User not found" });
        return;
      }

      const currentLives = userData[0]?.allive || 0;

      if (currentLives <= 0) {
        res
          .status(403)
          .json({ message: "No more lives! Cannot submit score." });
        return;
      }

      await serverdb
        .update(User)
        .set({ allive: currentLives - 1 })
        .where(eq(User.id, userId));

      let fullscore: number = calculateScore(time, starcount, iscompleted);

      const existingScore = await serverdb
        .select()
        .from(ScoreTable)
        .where(eq(ScoreTable.userId, userId));

      const minutes = Math.floor(time / 60);
      const seconds = time % 60;
      const formattedTime = `00:${minutes.toString().padStart(2, "0")}:${seconds.toString().padStart(2, "0")}`;

      const currentScore = existingScore[0]?.score ?? 0;
      if (existingScore.length === 0 || fullscore > currentScore) {
        const result = await serverdb
          .insert(ScoreTable)
          .values({
            userId: userId,
            completedTime: formattedTime,
            starscount: starcount,
            score: fullscore,
            iscompleted: iscompleted,
          })
          .onConflictDoUpdate({
            target: ScoreTable.userId,
            set: {
              score: fullscore,
              completedTime: formattedTime,
              starscount: starcount,
              iscompleted: iscompleted,
            },
          })
          .returning();

        console.log(result);
        res.status(200).json({
          message:
            existingScore.length === 0
              ? "New high score created!"
              : "New high score updated!",
          score: fullscore,
          remainingLives: currentLives - 1,
        });
      } else {
        res.status(200).json({
          message: "Previous score is higher, no update",
          currentHighScore: existingScore[0]?.score ?? 0,
          yourScore: fullscore,
        });
      }
    }
  } catch (error) {
    next(error);
  }
};

export const GetFullScore = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const allScoresWithUsers = await serverdb
      .select({
        scoreId: ScoreTable.id,
        score: ScoreTable.score,
        completedTime: ScoreTable.completedTime,
        starscount: ScoreTable.starscount,
        iscompleted: ScoreTable.iscompleted,
        userId: User.id,
        userName: User.name,
        userLives: User.allive,
      })
      .from(ScoreTable)
      .innerJoin(User, eq(ScoreTable.userId, User.id));

    res.status(200).json({
      success: true,
      allScores: allScoresWithUsers,
    });
  } catch (error) {
    next(error);
  }
};
