import User from './user';
import Message from './message';
import Media from './media';
import Group from './group';
import GroupMember from './groupMember';

// Associations for User
User.hasMany(Message, { foreignKey: 'senderId', as: 'sentMessages' }); // Changed alias
User.hasMany(Message, { foreignKey: 'receiverId', as: 'receivedMessages' }); // Changed alias
User.hasMany(Media, { foreignKey: 'userId', as: 'mediaFiles' }); // Changed alias
User.belongsToMany(Group, { through: GroupMember, foreignKey: 'userId', as: 'groups' }); // Changed alias

// Associations for Message
Message.belongsTo(User, { foreignKey: 'senderId', as: 'senderDetails' }); // Changed alias
Message.belongsTo(User, { foreignKey: 'receiverId', as: 'receiverDetails' }); // Changed alias
Message.hasMany(Media, { foreignKey: 'messageId', as: 'attachments' }); // Changed alias

// Associations for Group
Group.hasMany(GroupMember, { foreignKey: 'groupId', as: 'members' }); // Changed alias
Group.belongsToMany(User, { through: GroupMember, foreignKey: 'groupId', as: 'groupUsers' }); // Changed alias

export { User, Message, Media, Group, GroupMember };
