module AmountParser where

import           Data.Text (Text)
import qualified Data.Text as T
import qualified Hledger as HL
import           Text.Parsec

type Parser = Parsec String HL.JournalContext

parseAmount :: HL.JournalContext -> Text -> Either String HL.MixedAmount
parseAmount context t = case runParser (mixed <* optional spaces <* eof) context "" (T.unpack t) of
  Left err -> Left (show err)
  Right res -> Right res

mixed :: Parser HL.MixedAmount
mixed = HL.mixed <$> expr

expr :: Parser [HL.Amount]
expr = many1 (try $ lexeme factor)

factor :: Parser HL.Amount
factor =  (char '+' >> lexeme HL.amountp)
      <|> (char '-' >> flip HL.divideAmount (-1) <$> lexeme HL.amountp)
      <|> HL.amountp

lexeme :: Parser a -> Parser a
lexeme p = spaces >> p
