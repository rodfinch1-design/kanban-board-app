-- Kanban Board Application - PostgreSQL Database Schema
-- Full-stack task management system with users, boards, columns, tasks, comments, and tags

-- Enable UUID extension for generating unique IDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- USERS TABLE
-- ============================================
CREATE TABLE users (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      username VARCHAR(50) UNIQUE NOT NULL,
      email VARCHAR(255) UNIQUE NOT NULL,
      password_hash VARCHAR(255) NOT NULL,
      first_name VARCHAR(100),
      last_name VARCHAR(100),
      avatar_url VARCHAR(500),
      is_active BOOLEAN DEFAULT true,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      last_login TIMESTAMP WITH TIME ZONE
  );

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);

-- ============================================
-- BOARDS TABLE
-- ============================================
CREATE TABLE boards (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      name VARCHAR(255) NOT NULL,
      description TEXT,
      owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      is_public BOOLEAN DEFAULT false,
      background_color VARCHAR(7) DEFAULT '#FFFFFF',
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
  );

CREATE INDEX idx_boards_owner ON boards(owner_id);

-- ============================================
-- BOARD MEMBERS TABLE (Many-to-Many)
-- ============================================
CREATE TABLE board_members (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      board_id UUID NOT NULL REFERENCES boards(id) ON DELETE CASCADE,
      user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member', 'viewer')),
      added_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(board_id, user_id)
  );

CREATE INDEX idx_board_members_board ON board_members(board_id);
CREATE INDEX idx_board_members_user ON board_members(user_id);

-- ============================================
-- COLUMNS TABLE (Status columns in the board)
-- ============================================
CREATE TABLE columns (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      board_id UUID NOT NULL REFERENCES boards(id) ON DELETE CASCADE,
      name VARCHAR(100) NOT NULL,
      position INTEGER NOT NULL,
      wip_limit INTEGER DEFAULT NULL,
      color VARCHAR(7) DEFAULT '#E0E0E0',
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
  );

CREATE INDEX idx_columns_board ON columns(board_id);
CREATE INDEX idx_columns_position ON columns(board_id, position);

-- ============================================
-- TASKS TABLE
-- ============================================
CREATE TABLE tasks (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      board_id UUID NOT NULL REFERENCES boards(id) ON DELETE CASCADE,
      column_id UUID NOT NULL REFERENCES columns(id) ON DELETE CASCADE,
      title VARCHAR(500) NOT NULL,
      description TEXT,
      position INTEGER NOT NULL,
      priority VARCHAR(20) DEFAULT 'normal' CHECK (priority IN ('urgent', 'high', 'normal', 'low')),
      size VARCHAR(10) CHECK (size IN ('S', 'M', 'L', 'XL')),
      due_date DATE,
      start_date DATE,
      completed_at TIMESTAMP WITH TIME ZONE,
      created_by UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
      assigned_to UUID REFERENCES users(id) ON DELETE SET NULL,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
  );

CREATE INDEX idx_tasks_board ON tasks(board_id);
CREATE INDEX idx_tasks_column ON tasks(column_id);
CREATE INDEX idx_tasks_assigned ON tasks(assigned_to);
CREATE INDEX idx_tasks_position ON tasks(column_id, position);

-- ============================================
-- TAGS TABLE
-- ============================================
CREATE TABLE tags (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      board_id UUID NOT NULL REFERENCES boards(id) ON DELETE CASCADE,
      name VARCHAR(50) NOT NULL,
      color VARCHAR(7) DEFAULT '#808080',
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(board_id, name)
  );

CREATE INDEX idx_tags_board ON tags(board_id);

-- ============================================
-- TASK TAGS (Many-to-Many)
-- ============================================
CREATE TABLE task_tags (
      task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
      tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
      PRIMARY KEY (task_id, tag_id)
  );

CREATE INDEX idx_task_tags_task ON task_tags(task_id);
CREATE INDEX idx_task_tags_tag ON task_tags(tag_id);

-- ============================================
-- COMMENTS TABLE
-- ============================================
CREATE TABLE comments (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
      user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      content TEXT NOT NULL,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
  );

CREATE INDEX idx_comments_task ON comments(task_id);
CREATE INDEX idx_comments_user ON comments(user_id);

-- ============================================
-- ATTACHMENTS TABLE
-- ============================================
CREATE TABLE attachments (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
      filename VARCHAR(255) NOT NULL,
      file_url VARCHAR(500) NOT NULL,
      file_size INTEGER,
      mime_type VARCHAR(100),
      uploaded_by UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
  );

CREATE INDEX idx_attachments_task ON attachments(task_id);

-- ============================================
-- ACTIVITY LOG TABLE
-- ============================================
CREATE TABLE activity_logs (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      board_id UUID NOT NULL REFERENCES boards(id) ON DELETE CASCADE,
      user_id UUID REFERENCES users(id) ON DELETE SET NULL,
      action VARCHAR(50) NOT NULL,
      entity_type VARCHAR(50) NOT NULL,
      entity_id UUID NOT NULL,
      details JSONB,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
  );

CREATE INDEX idx_activity_logs_board ON activity_logs(board_id);
CREATE INDEX idx_activity_logs_user ON activity_logs(user_id);
CREATE INDEX idx_activity_logs_created ON activity_logs(created_at DESC);

-- ============================================
-- CHECKLISTS TABLE
-- ============================================
CREATE TABLE checklists (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
      title VARCHAR(255) NOT NULL,
      position INTEGER NOT NULL,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
  );

CREATE INDEX idx_checklists_task ON checklists(task_id);

-- ============================================
-- CHECKLIST ITEMS TABLE
-- ============================================
CREATE TABLE checklist_items (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      checklist_id UUID NOT NULL REFERENCES checklists(id) ON DELETE CASCADE,
      content VARCHAR(500) NOT NULL,
      is_completed BOOLEAN DEFAULT false,
      position INTEGER NOT NULL,
      completed_at TIMESTAMP WITH TIME ZONE,
      completed_by UUID REFERENCES users(id) ON DELETE SET NULL,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
  );

CREATE INDEX idx_checklist_items_checklist ON checklist_items(checklist_id);

-- ============================================
-- TRIGGERS FOR UPDATED_AT
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_boards_updated_at BEFORE UPDATE ON boards
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_columns_updated_at BEFORE UPDATE ON columns
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- SAMPLE DATA (Optional - for development)
-- ============================================
-- Uncomment to insert sample data

/*
INSERT INTO users (username, email, password_hash, first_name, last_name) VALUES
('demo_user', 'demo@kanban.com', '$2b$10$demohashedpassword', 'Demo', 'User'),
('john_doe', 'john@kanban.com', '$2b$10$demohashedpassword', 'John', 'Doe');

INSERT INTO boards (name, description, owner_id) VALUES
('My First Kanban Board', 'A demo board for testing', (SELECT id FROM users WHERE username = 'demo_user'));

INSERT INTO columns (board_id, name, position, color) VALUES
((SELECT id FROM boards LIMIT 1), 'Backlog', 1, '#9E9E9E'),
((SELECT id FROM boards LIMIT 1), 'To Do', 2, '#2196F3'),
((SELECT id FROM boards LIMIT 1), 'In Progress', 3, '#FF9800'),
((SELECT id FROM boards LIMIT 1), 'Review', 4, '#9C27B0'),
((SELECT id FROM boards LIMIT 1), 'Done', 5, '#4CAF50');
*/
