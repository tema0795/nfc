import { Background } from './background.tsx'

export const Login = () =>
{
    return (
      <main className="flex flex-col">
        <Background />
        <form className="flex flex-col px-9 h-[50vh] w-full items-center justify-center text-center gap-6">
            <input className="w-full h-13 p-3 text-[#A39C9C] font-bold italic bg-[#18233F]" placeholder="Логин"/>
            <input className="w-full h-13 p-3 text-[#A39C9C] font-bold italic bg-[#18233F]" placeholder="Пароль"/>
            <button className="w-full text-center text-[#FFFFFF] h-13 text-lg font-bold italic bg-[#3C4D89] cursor-pointer">
              Войти
            </button> 
        </form>
      </main>
    );
}