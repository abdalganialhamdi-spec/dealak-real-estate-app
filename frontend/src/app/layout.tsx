import type { Metadata } from 'next';
import { Inter, Tajawal } from 'next/font/google';
import './globals.css';

const inter = Inter({ subsets: ['latin'], variable: '--font-inter' });
const tajawal = Tajawal({ 
  subsets: ['arabic'], 
  weight: ['400', '500', '700', '800'],
  variable: '--font-tajawal' 
});

export const metadata: Metadata = {
  title: 'DEALAK - منصة العقارات في سوريا',
  description: 'بيع، إيجار، وإدارة العقارات في سوريا',
  keywords: ['عقارات', 'سوريا', 'بيع', 'إيجار', 'شقق', 'منازل'],
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ar" dir="rtl">
      <body className={`${inter.variable} ${tajawal.variable} font-sans`}>
        {children}
      </body>
    </html>
  );
}
