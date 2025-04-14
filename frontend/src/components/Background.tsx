import Logo from '../assets/logo.svg'
import BG from '../assets/background.svg'

export const Background = () => 
{
    return (
        <div className="flex items-center justify-center relative h-[50vh] w-screen">
          <img src={Logo} alt="logo" className="w-70 h-70 z-50 shadow-2xl" />
          <img src={BG} alt="bg" className="absolute inset-0 w-[150%] h-[150%] translate-y-[-15%] transition-transform z-0 object-cover" style={{display: 'inline-block', boxSizing: 'unset'}} />
        </div>
    )
}