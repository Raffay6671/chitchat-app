// src/models/user.ts
import { DataTypes, Model, Optional } from "sequelize";
import sequelize from "../config/database";

// Define the attributes of the User model
interface UserAttributes {
  id: string;
  username: string;
  email: string;
  password: string;
  displayName?: string;
  profilePicture?: string;
  refreshToken?: string | null; // ✅ Add refreshToken attribute
}

interface UserCreationAttributes extends Optional<UserAttributes, "id"> {}

class User
  extends Model<UserAttributes, UserCreationAttributes>
  implements UserAttributes
{
  public id!: string;
  public username!: string;
  public email!: string;
  public password!: string;
  public displayName?: string;
  public profilePicture?: string;
  public refreshToken?: string | null; // ✅ Add refreshToken property
}

User.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    username: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    displayName: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    profilePicture: {
      type: DataTypes.STRING,
      allowNull: true, // ✅ Allow it to be null
      defaultValue: "/uploads/default-avatar.png", // ✅ Default Profile Picture
    },
    refreshToken: {
      type: DataTypes.STRING, // ✅ Add refreshToken column
      allowNull: true, // User might not have a refresh token initially
    },
  },
  {
    sequelize,
    modelName: "users",
  }
);

export default User;
