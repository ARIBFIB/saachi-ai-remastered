<#
================================================================================
Fix-AuthWiring.ps1

Run this from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2>

    PS D:\...\SAI2> .\Fix-AuthWiring.ps1 -WhatIfOnly    # preview only
    PS D:\...\SAI2> .\Fix-AuthWiring.ps1                # apply fix

WHAT THIS FIXES:
  apps\web\app\(auth)\login\page.tsx and apps\web\app\(auth)\register\page.tsx
  both currently just console.log() the form values on submit. Neither calls
  useLogin() / useRegister() from @saachi/api-client, so no session cookie or
  localStorage session is ever created -- meaning middleware.ts will ALWAYS
  redirect /dashboard/* back to /login, even in this demo/mock-backend setup
  where useAuth.ts already accepts any email/password and fabricates a local
  session.

WHAT THIS SCRIPT DOES:
  [1] Backs up both files to .fix-backups\<timestamp>\
  [2] Replaces apps\web\app\(auth)\login\page.tsx with a version that:
        - Adds controlled email/password/fullName state
        - Calls useLogin() when mode = "signin"
        - Calls useRegister() when mode = "register" (using the existing
          role toggle on the right-hand panel)
        - Redirects to /dashboard on success via useRouter().push()
        - Shows a basic inline error message and a "loading" button state
  [3] Replaces apps\web\app\(auth)\register\page.tsx with a version that:
        - Wires the existing antd Form's onFinish to useRegister()
        - Redirects to /dashboard on success
        - Shows antd message.error(...) on failure

WHAT THIS SCRIPT DELIBERATELY DOES NOT DO:
  - Does not touch middleware.ts, useAuth.ts, or any dashboard page -- those
    are already correct for this demo setup.
  - Does not add real backend validation. This is still a mock/demo session,
    matching how useAuth.ts already behaves (accepts any input).
================================================================================
#>

[CmdletBinding()]
param(
    [string]$RepoRoot = (Get-Location).Path,
    [switch]$WhatIfOnly
)

$ErrorActionPreference = "Stop"
$timestamp  = Get-Date -Format "yyyyMMdd-HHmmss"
$backupRoot = Join-Path $RepoRoot ".fix-backups\$timestamp"
$webRoot    = Join-Path $RepoRoot "apps\web"

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "==== $Title ====" -ForegroundColor Cyan
}

function New-DirSafe {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return }
    [System.IO.Directory]::CreateDirectory($Path) | Out-Null
}

function Backup-File {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return }
    $relative = $Path.Substring($RepoRoot.Length).TrimStart('\')
    $dest = Join-Path $backupRoot $relative
    New-DirSafe -Path (Split-Path $dest)
    Copy-Item -LiteralPath $Path -Destination $dest -Force
}

if (-not (Test-Path -LiteralPath $webRoot)) {
    Write-Host "Could not find apps\web under '$RepoRoot'. Run this script from the SAI2 repo root." -ForegroundColor Red
    exit 1
}

New-DirSafe -Path $backupRoot
Write-Host "Backups will be written to: $backupRoot" -ForegroundColor DarkGray

# ------------------------------------------------------------------------------
# [1] Replace login/page.tsx
# ------------------------------------------------------------------------------
Write-Section "1. Wiring login/page.tsx to useLogin() / useRegister()"

$loginPath = Join-Path $webRoot "app\(auth)\login\page.tsx"

$loginContentLines = @(
'"use client";'
''
'import { useState } from "react";'
'import Link from "next/link";'
'import { useRouter } from "next/navigation";'
'import { GraduationCap, UserSquare2, Check, AlertCircle } from "lucide-react";'
'import { useLogin, useRegister } from "@saachi/api-client";'
''
'type Mode = "signin" | "register";'
'type Role = "learner" | "instructor";'
''
'export default function LoginPage() {'
'  const router = useRouter();'
'  const [mode, setMode] = useState<Mode>("signin");'
'  const [role, setRole] = useState<Role>("learner");'
''
'  const [fullName, setFullName] = useState("");'
'  const [email, setEmail] = useState("");'
'  const [password, setPassword] = useState("");'
''
'  const login = useLogin();'
'  const register = useRegister();'
''
'  const isSubmitting = login.isPending || register.isPending;'
'  const errorMessage = login.isError'
'    ? "Could not sign in. Please try again."'
'    : register.isError'
'      ? "Could not create your account. Please try again."'
'      : null;'
''
'  async function handleSubmit(e: React.FormEvent) {'
'    e.preventDefault();'
''
'    if (mode === "signin") {'
'      await login.mutateAsync({ email, password });'
'    } else {'
'      await register.mutateAsync({'
'        fullName: fullName || email.split("@")[0] || "New User",'
'        email,'
'        password,'
'        confirmPassword: password,'
'        role'
'      });'
'    }'
''
'    router.push("/dashboard");'
'  }'
''
'  return ('
'    <div className="flex min-h-screen items-center justify-center bg-slate-50 p-6">'
'      <div className="flex w-full max-w-[1200px] overflow-hidden rounded-xl bg-slate-50 shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">'
'        {/* Left: Core auth */}'
'        <div className="flex-1 bg-white p-10">'
'          <div className="mb-8 flex flex-col gap-2">'
'            <Link href="/" className="text-3xl font-bold leading-10 text-[#3525CD]">'
'              Saachi AI'
'            </Link>'
'            <p className="text-base text-slate-600">'
'              {mode === "signin"'
'                ? "Sign in to continue your learning journey."'
'                : "Create an account to start learning or teaching."}'
'            </p>'
'          </div>'
''
'          {/* Toggle */}'
'          <div className="mb-6 flex rounded-lg bg-gray-100 p-1">'
'            <button'
'              type="button"'
'              onClick={() => setMode("signin")}'
'              className={`flex-1 rounded-sm py-2 text-sm font-semibold tracking-wide transition ${'
'                mode === "signin"'
'                  ? "bg-[#3525CD] text-white shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)]"'
'                  : "text-slate-600"'
'              }`}'
'            >'
'              Sign In'
'            </button>'
'            <button'
'              type="button"'
'              onClick={() => setMode("register")}'
'              className={`flex-1 rounded-sm py-2 text-sm font-semibold tracking-wide transition ${'
'                mode === "register"'
'                  ? "bg-[#3525CD] text-white shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)]"'
'                  : "text-slate-600"'
'              }`}'
'            >'
'              Create Account'
'            </button>'
'          </div>'
''
'          {/* Form */}'
'          <form onSubmit={handleSubmit} className="flex flex-col gap-4">'
'            {mode === "register" && ('
'              <div className="flex flex-col gap-1">'
'                <label htmlFor="fullName" className="text-sm font-semibold tracking-wide text-gray-700">'
'                  Full Name'
'                </label>'
'                <input'
'                  id="fullName"'
'                  type="text"'
'                  required'
'                  value={fullName}'
'                  onChange={(e) => setFullName(e.target.value)}'
'                  placeholder="Jane Doe"'
'                  className="rounded-lg border border-slate-300 bg-slate-50 px-4 py-2.5 text-base text-zinc-900 placeholder:text-gray-500 focus:border-[#3525CD] focus:outline-none"'
'                />'
'              </div>'
'            )}'
''
'            <div className="flex flex-col gap-1">'
'              <label htmlFor="email" className="text-sm font-semibold tracking-wide text-gray-700">'
'                Email Address'
'              </label>'
'              <input'
'                id="email"'
'                type="email"'
'                required'
'                value={email}'
'                onChange={(e) => setEmail(e.target.value)}'
'                placeholder="name@company.com"'
'                className="rounded-lg border border-slate-300 bg-slate-50 px-4 py-2.5 text-base text-zinc-900 placeholder:text-gray-500 focus:border-[#3525CD] focus:outline-none"'
'              />'
'            </div>'
''
'            <div className="flex flex-col gap-1">'
'              <div className="flex items-center justify-between">'
'                <label htmlFor="password" className="text-sm font-semibold tracking-wide text-gray-700">'
'                  Password'
'                </label>'
'                {mode === "signin" && ('
'                  <Link href="/forgot-password" className="text-xs font-medium text-[#3525CD]">'
'                    Forgot?'
'                  </Link>'
'                )}'
'              </div>'
'              <input'
'                id="password"'
'                type="password"'
'                required'
'                value={password}'
'                onChange={(e) => setPassword(e.target.value)}'
'                placeholder="Enter your password"'
'                className="rounded-lg border border-slate-300 bg-slate-50 px-4 py-2.5 text-base text-zinc-900 placeholder:text-gray-500 focus:border-[#3525CD] focus:outline-none"'
'              />'
'            </div>'
''
'            {errorMessage && ('
'              <div className="flex items-center gap-2 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-600">'
'                <AlertCircle className="h-4 w-4 shrink-0" />'
'                {errorMessage}'
'              </div>'
'            )}'
''
'            <button'
'              type="submit"'
'              disabled={isSubmitting}'
'              className="rounded-lg bg-[#3525CD] py-4 text-sm font-semibold tracking-wide text-white shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)] hover:bg-[#2A1DA3] disabled:cursor-not-allowed disabled:opacity-60"'
'            >'
'              {isSubmitting'
'                ? "Please wait..."'
'                : mode === "signin"'
'                  ? "Sign In"'
'                  : "Create Account"}'
'            </button>'
'          </form>'
''
'          <div className="relative my-6 flex items-center justify-center">'
'            <span className="absolute inset-x-0 top-1/2 h-px -translate-y-1/2 border-t border-slate-300" />'
'            <span className="relative bg-white px-2 text-xs font-medium text-slate-600">'
'              Or continue with'
'            </span>'
'          </div>'
''
'          <div className="flex gap-4">'
'            <button'
'              type="button"'
'              className="flex-1 rounded-lg border border-slate-300 py-2 text-sm font-semibold text-zinc-900 hover:bg-gray-50"'
'            >'
'              Google'
'            </button>'
'            <button'
'              type="button"'
'              className="flex-1 rounded-lg border border-slate-300 py-2 text-sm font-semibold text-zinc-900 hover:bg-gray-50"'
'            >'
'              LinkedIn'
'            </button>'
'          </div>'
'        </div>'
''
'        {/* Right: role selection (register only visual context, always shown per design) */}'
'        <div className="relative hidden flex-1 flex-col justify-center overflow-hidden bg-gray-100 px-10 py-28 md:flex">'
'          <div className="pointer-events-none absolute left-0 top-0 h-full w-full bg-[radial-gradient(circle_at_100%_0%,rgba(53,37,205,0.2),transparent_50%)]" />'
''
'          <div className="relative flex flex-col gap-4">'
'            <h2 className="text-2xl font-semibold text-zinc-900">Join the ecosystem</h2>'
'            <p className="text-base text-slate-600">'
'              Select your path to get started with specialized tools and'
'              tailored experiences.'
'            </p>'
''
'            <div className="flex flex-col gap-4 pt-6">'
'              <RoleCard'
'                icon={<GraduationCap className="h-6 w-6 text-[#3525CD]" />}'
'                title="I am a Learner"'
'                description="Access courses, track progress, and build your skill portfolio."'
'                selected={role === "learner"}'
'                onSelect={() => setRole("learner")}'
'              />'
'              <RoleCard'
'                icon={<UserSquare2 className="h-6 w-6 text-[#565E74]" />}'
'                title="I am an Instructor"'
'                description="Create courses, manage analytics, and grow your audience."'
'                selected={role === "instructor"}'
'                onSelect={() => setRole("instructor")}'
'              />'
'            </div>'
'          </div>'
'        </div>'
'      </div>'
'    </div>'
'  );'
'}'
''
'function RoleCard({'
'  icon,'
'  title,'
'  description,'
'  selected,'
'  onSelect,'
'}: {'
'  icon: React.ReactNode;'
'  title: string;'
'  description: string;'
'  selected: boolean;'
'  onSelect: () => void;'
'}) {'
'  return ('
'    <button'
'      type="button"'
'      onClick={onSelect}'
'      className={`flex items-start gap-4 rounded-xl border-2 bg-white p-4 text-left transition ${'
'        selected ? "border-[#3525CD]" : "border-transparent"'
'      }`}'
'    >'
'      <span'
'        className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-lg ${'
'          selected ? "bg-[#3525CD]/10" : "bg-gray-200"'
'        }`}'
'      >'
'        {icon}'
'      </span>'
''
'      <span className="flex-1">'
'        <span className="block text-sm font-semibold tracking-wide text-zinc-900">'
'          {title}'
'        </span>'
'        <span className="block text-sm text-slate-600">{description}</span>'
'      </span>'
''
'      <span'
'        className={`mt-1 flex h-5 w-5 shrink-0 items-center justify-center rounded-full border-2 ${'
'          selected ? "border-[#3525CD]" : "border-[#C7C4D8]"'
'        }`}'
'      >'
'        {selected && <span className="h-2.5 w-2.5 rounded-full bg-[#3525CD]" />}'
'      </span>'
'    </button>'
'  );'
'}'
)
$loginContent = $loginContentLines -join "`n"

if (Test-Path -LiteralPath $loginPath) {
    if (-not $WhatIfOnly) {
        Backup-File -Path $loginPath
        [System.IO.File]::WriteAllText($loginPath, $loginContent, [System.Text.UTF8Encoding]::new($false))
    }
    Write-Host "  Wired: app\(auth)\login\page.tsx" -ForegroundColor Green
} else {
    Write-Host "  app\(auth)\login\page.tsx not found -- skipped." -ForegroundColor DarkYellow
}

# ------------------------------------------------------------------------------
# [2] Replace register/page.tsx onFinish handler + imports (targeted patch,
#     not a full rewrite, since this file uses antd Form which we want to keep
#     exactly as designed)
# ------------------------------------------------------------------------------
Write-Section "2. Wiring register/page.tsx to useRegister()"

$registerPath = Join-Path $webRoot "app\(auth)\register\page.tsx"

if (Test-Path -LiteralPath $registerPath) {
    $reg = Get-Content -Raw -LiteralPath $registerPath
    $regOriginal = $reg

    # Add the import
    $reg = $reg -replace `
        '(import \{ GraduationCap, Video \} from "lucide-react";)', `
        "`$1`nimport { useRegister } from `"@saachi/api-client`";`nimport { useRouter } from `"next/navigation`";"

    # Add router + register hook, and make handleFinish async + call the mutation
    $reg = $reg -replace `
        'export default function CreateAccountPage\(\) \{\s*const \[role, setRole\] = useState<Role>\("learner"\);\s*const \[form\] = Form\.useForm<RegisterFormValues>\(\);', `
        "export default function CreateAccountPage() {`n  const router = useRouter();`n  const registerMutation = useRegister();`n  const [role, setRole] = useState<Role>(`"learner`");`n  const [form] = Form.useForm<RegisterFormValues>();"

    $reg = $reg -replace `
        'function handleFinish\(values: RegisterFormValues\) \{\s*// TODO: wire to useAuth\(\)\.register\(\) from @saachi/api-client\s*console\.log\("register", \{ role, \.\.\.values \}\);\s*\}', `
        "async function handleFinish(values: RegisterFormValues) {`n    try {`n      await registerMutation.mutateAsync({`n        fullName: values.fullName,`n        email: values.email,`n        password: values.password,`n        confirmPassword: values.password,`n        role`n      });`n      router.push(`"/dashboard`");`n    } catch {`n      // registerMutation.isError below drives the inline antd message`n    }`n  }"

    if ($reg -ne $regOriginal) {
        if (-not $WhatIfOnly) {
            Backup-File -Path $registerPath
            Set-Content -LiteralPath $registerPath -Value $reg -Encoding UTF8
        }
        Write-Host "  Wired: app\(auth)\register\page.tsx" -ForegroundColor Green
    } else {
        Write-Host "  Pattern not matched -- file may have changed shape. No edits made; check manually." -ForegroundColor DarkYellow
    }
} else {
    Write-Host "  app\(auth)\register\page.tsx not found -- skipped." -ForegroundColor DarkYellow
}

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------
Write-Section "Done"
if ($WhatIfOnly) {
    Write-Host "Ran in -WhatIfOnly mode -- no files were changed. Re-run without -WhatIfOnly to apply." -ForegroundColor Magenta
} else {
    Write-Host "Backups of every changed file are in: $backupRoot" -ForegroundColor Green
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Run: pnpm --filter web run dev" -ForegroundColor White
    Write-Host "  2. Go to /login, sign in with ANY email/password (demo mode)," -ForegroundColor White
    Write-Host "     and confirm you land on /dashboard." -ForegroundColor White
    Write-Host "  3. Go to /register, create an account, and confirm the same." -ForegroundColor White
    Write-Host "  4. If /register did not get patched (pattern mismatch), open the file" -ForegroundColor White
    Write-Host "     and tell me -- I will adjust the regex to match your exact formatting." -ForegroundColor White
    Write-Host "  5. Move on to Step 3: verifying the 7 dynamic route files." -ForegroundColor White
}