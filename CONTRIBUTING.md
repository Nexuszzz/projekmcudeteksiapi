# 🤝 Contributing to IoT Fire Detection Dashboard

Thank you for considering contributing to this project! 

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing](#testing)

## 📜 Code of Conduct

Be respectful and constructive in all interactions.

## 🚀 Getting Started

### Prerequisites

- Node.js v18+
- npm or pnpm
- Git
- MQTT broker (for testing)

### Setup Development Environment

```bash
# Fork and clone repository
git clone https://github.com/your-username/iot-fire-detection-dashboard.git
cd iot-fire-detection-dashboard

# Install dependencies
npm install

# Copy environment template
cp .env.example .env

# Edit .env with your MQTT broker details
# Start development server
npm run dev
```

## 🔄 Development Workflow

### Branch Strategy

- `main` - Production-ready code
- `develop` - Development branch
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `hotfix/*` - Urgent production fixes

### Creating a Feature

```bash
# Create feature branch from develop
git checkout develop
git pull origin develop
git checkout -b feature/awesome-feature

# Make changes
# Commit changes
git add .
git commit -m "feat: add awesome feature"

# Push to your fork
git push origin feature/awesome-feature

# Create Pull Request to develop
```

## 💻 Coding Standards

### TypeScript

- Use **strict mode** TypeScript
- Explicit types over `any`
- Prefer interfaces for object types
- Use type guards for runtime validation

**Good**:

```typescript
interface TelemetryData {
  id: string
  temperature: number | null
}

function processTelemetry(data: TelemetryData): void {
  // ...
}
```

**Bad**:

```typescript
function processTelemetry(data: any) {
  // ...
}
```

### React Components

- Functional components with hooks
- Props interface for each component
- Use semantic HTML
- Accessibility (ARIA labels, alt text)

**Example**:

```typescript
interface ButtonProps {
  label: string
  onClick: () => void
  disabled?: boolean
}

export function Button({ label, onClick, disabled = false }: ButtonProps) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className="px-4 py-2 bg-primary-600 text-white rounded"
      aria-label={label}
    >
      {label}
    </button>
  )
}
```

### File Naming

- Components: `PascalCase.tsx`
- Hooks: `useCamelCase.ts`
- Utilities: `camelCase.ts`
- Types: `camelCase.ts`

### Code Organization

```
src/
├── components/     # React components
├── hooks/          # Custom hooks
├── store/          # State management
├── types/          # TypeScript types
├── utils/          # Utility functions
└── App.tsx         # Main app
```

## 📝 Commit Guidelines

Follow **Conventional Commits** specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style (formatting, missing semicolons)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

### Examples

```bash
feat(chart): add zoom functionality to live chart

fix(mqtt): resolve connection timeout issue

docs(readme): update installation instructions

style(components): apply prettier formatting

refactor(store): simplify telemetry data management

test(validation): add tests for payload parsing

chore(deps): update dependencies to latest versions
```

## 🔀 Pull Request Process

### Before Submitting

1. **Test your changes** locally
2. **Run linter**: `npm run lint`
3. **Format code**: `npm run format`
4. **Run tests**: `npm test`
5. **Update documentation** if needed
6. **Check build**: `npm run build`

### PR Checklist

- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No new warnings or errors
- [ ] Tests added/updated
- [ ] Commit messages follow convention
- [ ] Branch is up-to-date with base

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
How has this been tested?

## Screenshots (if applicable)

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Tests pass
- [ ] Documentation updated
```

### Review Process

1. Submit PR to `develop` branch
2. Automated checks must pass
3. At least 1 approval required
4. Address review feedback
5. Maintainer will merge

## 🧪 Testing

### Unit Tests

```bash
# Run tests
npm test

# Watch mode
npm test -- --watch

# Coverage
npm test -- --coverage
```

### Manual Testing

1. **MQTT Connection**: Test connect/disconnect
2. **Data Visualization**: Verify charts update
3. **Controls**: Test buzzer and threshold
4. **Export**: Test CSV/JSONL export
5. **Responsive**: Test on mobile/tablet
6. **Dark Mode**: Toggle and verify
7. **Edge Cases**: Invalid payloads, disconnections

### Test Checklist

- [ ] All unit tests pass
- [ ] Manual testing completed
- [ ] Tested on Chrome, Firefox, Safari
- [ ] Tested on mobile devices
- [ ] Dark mode works correctly
- [ ] No console errors

## 🐛 Bug Reports

### Template

```markdown
**Describe the bug**
Clear description of the bug

**To Reproduce**
Steps to reproduce:
1. Go to '...'
2. Click on '...'
3. See error

**Expected behavior**
What should happen

**Screenshots**
If applicable

**Environment:**
- OS: [e.g. Windows 10]
- Browser: [e.g. Chrome 120]
- Version: [e.g. 1.0.0]

**Additional context**
Any other information
```

## ✨ Feature Requests

### Template

```markdown
**Is your feature request related to a problem?**
Description of the problem

**Describe the solution**
Clear description of desired solution

**Describe alternatives**
Alternative solutions considered

**Additional context**
Mockups, examples, etc.
```

## 📚 Resources

- [React Documentation](https://react.dev)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Zustand Documentation](https://zustand-demo.pmnd.rs/)
- [MQTT.js Documentation](https://github.com/mqttjs/MQTT.js)
- [Tailwind CSS](https://tailwindcss.com/docs)

## 🙏 Recognition

Contributors will be added to the README.

## ❓ Questions?

- Open an issue with `question` label
- Join discussions
- Email: support@example.com

---

**Thank you for contributing! 🎉**
