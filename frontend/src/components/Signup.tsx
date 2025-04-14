import { Background } from './background.tsx'

export const Signup = () =>
{
    return (
      <main className="flex flex-col">
        <Background />
        <form className="flex flex-col px-9 h-[50vh] w-full items-center justify-center text-center gap-6">
            <input className="w-full h-13 p-3 text-[#A39C9C] font-bold italic bg-[#18233F]" placeholder="Почта"/>
            <input className="w-full h-13 p-3 text-[#A39C9C] font-bold italic bg-[#18233F]" placeholder="Пароль"/>
            <input className="w-full h-13 p-3 text-[#A39C9C] font-bold italic bg-[#18233F]" placeholder="Подтверждение пароля"/>
            <button className="w-full text-center text-[#3C4D89] h-13 text-lg font-bold italic bg-[white] cursor-pointer ">
                Зарегистрироваться
            </button>
        </form>
      </main>
    );
}