// src/seedUsers.ts
import User from './models/user';
import sequelize from './config/database';
import bcrypt from 'bcrypt';

// ✅ Seed Users Function
const seedUsers = async () => {
  try {
    await sequelize.sync({ force: true }); // ⚠️ Resets my database (use cautiously in production)

    const users = [
      {
        username: 'Alex Linderson',
        email: 'alex.linderson@example.com',
        password: 'securePass123!',
        displayName: 'Alex',
        profilePicture: '/uploads/user1.png',
      },
      {
        username: 'Rafay Arshad',
        email: 'rafay.abbasi6671@gmail.com',
        password: 'rafayStrongPass123!',
        displayName: 'Rafay',
        profilePicture: '/uploads/user2.png',
      },
      {
        username: 'John Abraham',
        email: 'john.abraham@example.com',
        password: 'johnSecure456!',
        displayName: 'John',
        profilePicture: '/uploads/user4.png',
      },
      {
        username: 'Sabila Sayma',
        email: 'sabila.sayma@example.com',
        password: 'sabilaPass789!',
        displayName: 'Sabila',
        profilePicture: '/uploads/user3.png',
      },
      {
        username: 'John Borino',
        email: 'john.borino@example.com',
        password: 'borinoPass321!',
        displayName: 'Borino',
        profilePicture: '/uploads/user5.png',
      },
    ];

    // ✅ Hash passwords and insert users into the database
    for (const user of users) {
      const hashedPassword = await bcrypt.hash(user.password, 10);
      await User.create({ ...user, password: hashedPassword });
    }

    console.log('✅ Users seeded successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding users:', error);
    process.exit(1);
  }
};

seedUsers();
