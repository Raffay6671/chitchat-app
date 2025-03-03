import User from "./user";
import Message from "./message";
import Media from "./media";
import Group from "./group";
import GroupMember from "./groupMember";
import GroupMessage from "./groupMessage";

// ✅ Associations for User
User.hasMany(Message, { foreignKey: "senderId", as: "sentMessages" });
User.hasMany(Message, { foreignKey: "receiverId", as: "receivedMessages" });
User.hasMany(Media, { foreignKey: "userId", as: "mediaFiles" });
User.belongsToMany(Group, {
  through: GroupMember,
  foreignKey: "userId",
  as: "groups",
});
User.hasMany(GroupMessage, { foreignKey: "senderId", as: "groupMessages" }); // ✅ User can send multiple group messages

// ✅ Associations for Message
Message.belongsTo(User, { foreignKey: "senderId", as: "senderDetails" });
Message.belongsTo(User, { foreignKey: "receiverId", as: "receiverDetails" });
Message.hasMany(Media, { foreignKey: "messageId", as: "attachments" });

// ✅ Associations for Group
Group.hasMany(GroupMember, { foreignKey: "groupId", as: "members" });
Group.belongsToMany(User, {
  through: GroupMember,
  foreignKey: "groupId",
  as: "groupUsers",
});
Group.hasMany(GroupMessage, { foreignKey: "groupId", as: "messages" }); // ✅ Group can have multiple messages

// ✅ Associations for GroupMessage
GroupMessage.belongsTo(User, { foreignKey: "senderId", as: "sender" }); // ✅ Each group message is sent by a user
GroupMessage.belongsTo(Group, { foreignKey: "groupId", as: "group" }); // ✅ Each group message belongs to a group

export { User, Message, Media, Group, GroupMember, GroupMessage };
