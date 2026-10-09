import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { AuthProvider } from '../../../core/auth'
import { LoginPage } from './LoginPage'

describe('LoginPage', () => {
  const renderLoginPage = () =>
    render(
      <AuthProvider>
        <LoginPage />
      </AuthProvider>
    )

  it('renders branding panel and login card elements', async () => {
    renderLoginPage()

    expect(await screen.findByText('VIEGYM ADMIN')).toBeInTheDocument()
    expect(screen.getByText('Vận hành khỏe hơn.')).toBeInTheDocument()
    expect(screen.getByText('Dữ liệu chính xác.')).toBeInTheDocument()
    expect(screen.getByText('Chỉ chấp nhận tài khoản ADMIN')).toBeInTheDocument()
    expect(screen.getByLabelText(/^email quản trị$/i)).toHaveValue('admin@viegym.com')
  })

  it('toggles password visibility when toggle button is clicked', async () => {
    const user = userEvent.setup()
    renderLoginPage()

    const passwordInput = screen.getByLabelText(/^mật khẩu$/i)
    const toggleButton = screen.getByRole('button', { name: /hiện hoặc ẩn mật khẩu/i })

    expect(passwordInput).toHaveAttribute('type', 'password')

    await user.click(toggleButton)
    expect(passwordInput).toHaveAttribute('type', 'text')

    await user.click(toggleButton)
    expect(passwordInput).toHaveAttribute('type', 'password')
  })

  it('opens and closes dialog modals for help and security guidelines', async () => {
    const user = userEvent.setup()
    renderLoginPage()

    // Open Help modal
    const helpButton = screen.getByRole('button', { name: /trợ giúp kỹ thuật/i })
    await user.click(helpButton)

    expect(screen.getByText('Trung tâm hỗ trợ kỹ thuật VieGym Ops')).toBeInTheDocument()

    // Close modal
    const closeBtn = screen.getByRole('button', { name: /đã hiểu/i })
    await user.click(closeBtn)

    expect(screen.queryByText('Trung tâm hỗ trợ kỹ thuật VieGym Ops')).not.toBeInTheDocument()
  })
})
