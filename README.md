# 📋 Kanban Board Application

A modern, full-stack Kanban board application built with Node.js/Express backend, PostgreSQL database, and a drag-and-drop interface for efficient task management.

## 🌟 Features

- **Drag-and-Drop Interface**: Intuitive task card movement between columns
- - **Real-time Updates**: Live synchronization across multiple users
  - - **Custom Workflows**: Define your own status columns (Backlog, Ready, In Progress, Review, Blocked, Done)
    - - **Task Management**:
      -   - Priority levels (Urgent, High, Normal, Low)
          -   - Due dates and time tracking
              -   - Subtasks and checklists
                  -   - Tags and labels
                      -   - File attachments
                          -   - Comments and activity history
                              - - **Team Collaboration**: Assign tasks to team members
                                - - **WIP Limits**: Set work-in-progress limits per column
                                  - - **Filtering & Search**: Find tasks quickly
                                    - - **Export Options**: Export board data (JSON, CSV)
                                     
                                      - ## 🛠️ Tech Stack
                                     
                                      - ### Backend
                                      - - **Node.js** + **Express.js** - Server framework
                                        - - **PostgreSQL** - Relational database
                                          - - **Sequelize** - ORM for database management
                                            - - **JWT** - Authentication
                                              - - **Socket.io** - Real-time updates
                                               
                                                - ### Frontend
                                                - - **React** (or Vue.js) - UI framework
                                                  - - **React Beautiful DnD** - Drag and drop functionality
                                                    - - **Axios** - HTTP client
                                                      - - **Tailwind CSS** - Styling
                                                       
                                                        - ### DevOps
                                                        - - **Docker** - Containerization
                                                          - - **GitHub Actions** - CI/CD
                                                           
                                                            - ## 📁 Project Structure
                                                           
                                                            - ```
                                                              kanban-board-app/
                                                              ├── backend/
                                                              │   ├── src/
                                                              │   │   ├── config/         # Database & environment config
                                                              │   │   ├── controllers/    # Route controllers
                                                              │   │   ├── models/         # Database models
                                                              │   │   ├── routes/         # API routes
                                                              │   │   ├── middleware/     # Auth, validation, error handling
                                                              │   │   ├── services/       # Business logic
                                                              │   │   └── server.js       # Entry point
                                                              │   ├── tests/              # Backend tests
                                                              │   ├── package.json
                                                              │   └── Dockerfile
                                                              ├── frontend/
                                                              │   ├── public/
                                                              │   ├── src/
                                                              │   │   ├── components/     # React components
                                                              │   │   ├── pages/          # Page components
                                                              │   │   ├── hooks/          # Custom React hooks
                                                              │   │   ├── services/       # API calls
                                                              │   │   ├── utils/          # Helper functions
                                                              │   │   ├── styles/         # CSS/Tailwind
                                                              │   │   └── App.js
                                                              │   ├── package.json
                                                              │   └── Dockerfile
                                                              ├── database/
                                                              │   ├── migrations/         # Database migrations
                                                              │   ├── seeders/            # Sample data
                                                              │   └── schema.sql          # Database schema
                                                              ├── docs/
                                                              │   ├── API.md              # API documentation
                                                              │   ├── ARCHITECTURE.md     # System architecture
                                                              │   └── KANBAN_GUIDE.md     # Kanban methodology guide
                                                              ├── docker-compose.yml
                                                              ├── .env.example
                                                              ├── .gitignore
                                                              ├── LICENSE
                                                              └── README.md
                                                              ```

                                                              ## 🚀 Getting Started

                                                              ### Prerequisites

                                                              - Node.js (v18+)
                                                              - - PostgreSQL (v14+)
                                                                - - npm or yarn
                                                                  - - Docker (optional)
                                                                   
                                                                    - ### Installation
                                                                   
                                                                    - 1. **Clone the repository**
                                                                      2.    ```bash
                                                                               git clone https://github.com/rodfinch1-design/kanban-board-app.git
                                                                               cd kanban-board-app
                                                                               ```

                                                                            2. **Set up environment variables**
                                                                            3.    ```bash
                                                                                     cp .env.example .env
                                                                                     # Edit .env with your database credentials
                                                                                     ```

                                                                                  3. **Install dependencies**
                                                                                  4.    ```bash
                                                                                           # Backend
                                                                                           cd backend
                                                                                           npm install

                                                                                           # Frontend
                                                                                           cd ../frontend
                                                                                           npm install
                                                                                           ```

                                                                                        4. **Set up the database**
                                                                                        5.    ```bash
                                                                                                 cd backend
                                                                                                 npm run db:migrate
                                                                                                 npm run db:seed  # Optional: add sample data
                                                                                                 ```

                                                                                              5. **Run the application**
                                                                                              6.    ```bash
                                                                                                       # Terminal 1 - Backend
                                                                                                       cd backend
                                                                                                       npm run dev

                                                                                                       # Terminal 2 - Frontend
                                                                                                       cd frontend
                                                                                                       npm start
                                                                                                       ```
                                                                                                    
                                                                                                    6. **Access the application**
                                                                                                    7.    - Frontend: http://localhost:3000
                                                                                                          -    - Backend API: http://localhost:5000/api
                                                                                                           
                                                                                                               - ### Docker Setup (Alternative)
                                                                                                           
                                                                                                               - ```bash
                                                                                                                 docker-compose up -d
                                                                                                                 ```
                                                                                                                 
                                                                                                                 ## 📊 Database Schema
                                                                                                                 
                                                                                                                 ### Main Tables
                                                                                                                 - **users** - User accounts and authentication
                                                                                                                 - - **boards** - Kanban boards
                                                                                                                   - - **columns** - Status columns (customizable)
                                                                                                                     - - **tasks** - Task cards
                                                                                                                       - - **comments** - Task comments
                                                                                                                         - - **attachments** - File uploads
                                                                                                                           - - **tags** - Task labels
                                                                                                                            
                                                                                                                             - ## 🔌 API Endpoints
                                                                                                                            
                                                                                                                             - ### Authentication
                                                                                                                             - - `POST /api/auth/register` - Register new user
                                                                                                                               - - `POST /api/auth/login` - Login user
                                                                                                                                 - - `GET /api/auth/me` - Get current user
                                                                                                                                  
                                                                                                                                   - ### Boards
                                                                                                                                   - - `GET /api/boards` - Get all boards
                                                                                                                                     - - `POST /api/boards` - Create board
                                                                                                                                       - - `GET /api/boards/:id` - Get board details
                                                                                                                                         - - `PUT /api/boards/:id` - Update board
                                                                                                                                           - - `DELETE /api/boards/:id` - Delete board
                                                                                                                                            
                                                                                                                                             - ### Tasks
                                                                                                                                             - - `GET /api/tasks` - Get all tasks
                                                                                                                                               - - `POST /api/tasks` - Create task
                                                                                                                                                 - - `GET /api/tasks/:id` - Get task details
                                                                                                                                                   - - `PUT /api/tasks/:id` - Update task
                                                                                                                                                     - - `DELETE /api/tasks/:id` - Delete task
                                                                                                                                                       - - `PATCH /api/tasks/:id/move` - Move task to different column
                                                                                                                                                        
                                                                                                                                                         - *See [API Documentation](docs/API.md) for complete API reference*
                                                                                                                                                        
                                                                                                                                                         - ## 🧪 Testing
                                                                                                                                                        
                                                                                                                                                         - ```bash
                                                                                                                                                           # Backend tests
                                                                                                                                                           cd backend
                                                                                                                                                           npm test

                                                                                                                                                           # Frontend tests
                                                                                                                                                           cd frontend
                                                                                                                                                           npm test

                                                                                                                                                           # E2E tests
                                                                                                                                                           npm run test:e2e
                                                                                                                                                           ```
                                                                                                                                                           
                                                                                                                                                           ## 📖 Kanban Methodology
                                                                                                                                                           
                                                                                                                                                           This application implements a proper Kanban workflow with:
                                                                                                                                                           
                                                                                                                                                           - **Pull System**: Work is pulled into "In Progress" when capacity exists
                                                                                                                                                           - - **WIP Limits**: Limits work-in-progress to improve flow
                                                                                                                                                             - - **Visual Management**: Board shows all work and bottlenecks
                                                                                                                                                               - - **Continuous Flow**: Tasks move smoothly from left to right
                                                                                                                                                                 - - **Definition of Ready**: Cards must meet criteria before starting
                                                                                                                                                                   - - **Definition of Done**: Clear completion criteria
                                                                                                                                                                    
                                                                                                                                                                     - See [Kanban Guide](docs/KANBAN_GUIDE.md) for best practices.
                                                                                                                                                                    
                                                                                                                                                                     - ## 🔐 Security
                                                                                                                                                                    
                                                                                                                                                                     - - JWT-based authentication
                                                                                                                                                                       - - Password hashing with bcrypt
                                                                                                                                                                         - - SQL injection protection (parameterized queries)
                                                                                                                                                                           - - XSS protection
                                                                                                                                                                             - - CORS configuration
                                                                                                                                                                               - - Rate limiting
                                                                                                                                                                                 - - Input validation
                                                                                                                                                                                  
                                                                                                                                                                                   - ## 🤝 Contributing
                                                                                                                                                                                  
                                                                                                                                                                                   - Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details.
                                                                                                                                                                                  
                                                                                                                                                                                   - 1. Fork the repository
                                                                                                                                                                                     2. 2. Create a feature branch (`git checkout -b feature/amazing-feature`)
                                                                                                                                                                                        3. 3. Commit your changes (`git commit -m 'Add amazing feature'`)
                                                                                                                                                                                           4. 4. Push to the branch (`git push origin feature/amazing-feature`)
                                                                                                                                                                                              5. 5. Open a Pull Request
                                                                                                                                                                                                
                                                                                                                                                                                                 6. ## 📝 License
                                                                                                                                                                                                
                                                                                                                                                                                                 7. This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
                                                                                                                                                                                                
                                                                                                                                                                                                 8. ## 👤 Author
                                                                                                                                                                                                
                                                                                                                                                                                                 9. **Rod Finch**
                                                                                                                                                                                                 10. - GitHub: [@rodfinch1-design](https://github.com/rodfinch1-design)
                                                                                                                                                                                                    
                                                                                                                                                                                                     - ## 🙏 Acknowledgments
                                                                                                                                                                                                    
                                                                                                                                                                                                     - - Inspired by Trello, Jira, and ClickUp
                                                                                                                                                                                                       - - Built with guidance from David Anderson's Kanban book
                                                                                                                                                                                                         - - React Beautiful DnD library for drag-and-drop
                                                                                                                                                                                                          
                                                                                                                                                                                                           - ---
                                                                                                                                                                                                           
                                                                                                                                                                                                           **⭐ Star this repo if you find it helpful!**
