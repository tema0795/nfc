import { Background } from './background.tsx'

export const About = () =>
{
    return (
      <main className="flex flex-col overflow-hidden">
        <Background />
        <form className="flex flex-col px-9 h-[50vh] w-full items-center justify-center text-center gap-1">
            <h1 className="text-[32px] italic font-[700] text-white z-25">Приветствую в Onymus!</h1>
            <p className="text-[20px] italic mb-5 font-[700] text-[#3C4D89] z-25">Это быстрое и удобное средство для доступа к знаниям!</p>
            <div className="flex flex-col w-full items-center justify-center gap-3">
                <a href="/Signup" className="w-full h-13 p-3 text-[20px] font-[700] italic text-[#3C4D89] bg-white cursor-pointer">
                    Зарегистрироваться
                </a>
                <a href="/Login" className="w-full h-13 p-3 text-[20px] font-[700] text-white italic bg-[#3C4D89] cursor-pointer">
                    Войти
                </a>
            </div>
        </form>
      </main>
    );
}