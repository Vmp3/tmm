---Módulo de funções de uso geral para TVD v1.3.4
--@author Manoel Campos da Silva Filho
--<a href="http://manoelcampos.com">http://manoelcampos.com</a>
--@license Atribuição-Uso não-comercial-Compartilhamento pela mesma licença http://creativecommons.org/licenses/by-nc-sa/2.5/br/
--@class module
local logging = require('app/shared/utils/logging')
local math = require('math')
local util = {}

---Alterar o número do item atual de uma lista de itens (uma tabela por exemplo),
--considerando o total de elementos da lista.
--@param itemIndex Número do item atual na lista
--@param forward Se true, incrementa o itemIndex para avançar ao próximo item, 
--senão, decrementa o itemIndex para voltar ao item anterior
--@param maxValue Valor máximo que o itemIndex pode assumir (total de itens na lista)
--@param circularList Se true, indica que a lista é circular, assim, 
--se tentar ir além do último elemento, volta para o primeiro,
--e se tentar retroceder antes do primeiro, vai para o último.
--@return Retorna o novo itemIndex 
function util.moveItemIndex(itemIndex, forward, maxValue, circularList)
    if forward then
       if (itemIndex == maxValue) then
          if circularList then
             return 1
          end
       else
          return itemIndex + 1
       end
    else
       if itemIndex <= 1 then
          if circularList then
             return maxValue
          end
       else
          return itemIndex - 1
       end
    end

    --Se chegou até aqui, não altera o itemIndex, retornando o mesmo.
    --Isto ocorrerá somente se circularList for false (não é uma lista circular),
    --assim, se tentar ir além do último elemento, não volta para o primeiro,
    --e se tentar retroceder antes do primeiro, não vai para o último 
    return itemIndex
end

---Clona uma tabela
--@param tb Tabela ser clonada
--@return Retorna a nova tabela
function util.cloneTable(tb)
  local result = {}
  for k, v in pairs(tb) do
    result[k] = v
  end
  return result
end

---Imprime uma tabela, de forma recursiva
--@param tb A tabela a ser impressa
--@param level Apenas usado internamente para
--imprimir espaços para representar os níveis
--dentro da tabela.
function util.printable(tb, level)
  level = level or 1
  local spaces = string.rep(' ', level*2)
  for k, v in pairs(tb) do
      if type(v) ~= "table" then
         logging.table(spaces .. k..'='..tostring(v))
      else
         logging.table(spaces .. k)
         level = level + 1
         util.printable(v, level)
      end
  end
end

function util.tableToString(tb, level)
   level = level or 1
   local spaces = string.rep(' ', level*2)
   local result = ''
   if type(tb) ~= 'table' then return 'not a table' end
   for k, v in pairs(tb) do
       if type(v) ~= "table" then
         result = result .. spaces .. k .. '=' ..tostring(v) .. ' '
       else
          level = level + 1
          util.tableToString(v, level)
       end
   end
   return result
 end

function util.compileTable(table)
   local index = 1
   local holder = "{"
   while true do
      if type(table[index]) == "function" then
         index = index + 1
      elseif type(table[index]) == "table" then
         holder = holder..util.compileTable(table[index])
      elseif type(table[index]) == "number" then
         holder = holder..tostring(table[index])
      elseif type(table[index]) == "string" then
         holder = holder.."\""..table[index].."\""
      elseif table[index] == nil then
         holder = holder.."nil"
      elseif type(table[index]) == "boolean" then
         holder = holder..(table[index] and "true" or "false")
      end
      if index + 1 > #table then
        break
      end
      holder = holder..","
      index = index + 1
   end
   return holder.."}"
end

---Recebe uma string e quebra a mesma em várias linhas
--@param text String a ser quebrada em várias linhas
--@param maxLineSize Quantidade máxima de caracteres por linha
--@return Retorna uma tabela onde cada item contém uma linha
--de texto, no tamanho máximo de maxLineSize
function util.breakString(text, maxLineSize)
  local t = {}
  local str = text
  local i, fim = 1, 0

  if (str == nil) or (str == "") then
     return nil
  end

  --Substitui quebras de linha por espaço vazio
  str = str:gsub("\n", " ")
  str = str:gsub("\r", " ")

  --Percorre o texto, quebrando o mesmo, até chegar ao seu final
  while i <= #str do
     if i > #str then
        t:insert(str)
     else
        fim = i+maxLineSize-1
        if fim > #str then
           fim = #str
        else
            --Se o caracter onde a string deve ser quebrada
            --não for um espaço, procura o próximo espaço
            if str:byte(fim) ~= 32 then
               --A substring é obtida a partir do 1o caractere até a posição
               --final devido ser necessário obter um índice
               --absoluto (relativo a string inteira) do último espaço
               --encontrado antes da posição atual na string (variável fim)
               local aux = str:sub(1, fim)
               -- print("\t\t\t", aux)
               --Inverte o trecho da string para procurar o primeiro espaço
               --existente para quebrar a string 
               --(tal 1o espaço será o último na string sem estar invertida)
               aux = aux:reverse()
               fim = aux:find(' ')
               -- print("\t\t\t", aux, "fim:",fim)
               --Como a string está invertida, calcula qual a posição do espaço
               --na string original 
               fim = #aux - fim + 1

               --fim = str:find(' ', fim)
               if fim == nil then
                  fim = #str
               end
            end
        end
        table.insert(t, str:sub(i, fim))
        i=fim+1
     end
  end
--   util.printable(t)
  return t
end

---Imprime um texto na tela, quebrando o mesmo nos limites
--horizontais da área do canvas.
--@param areaWidth Largura a área disponível para impressão
--@parma x Posição x onde o texto deve ser impresso
--@param initialY Posição y inicial a ser impresso o texto
--@param text Texto a ser impresso, sendo quebrado em
--linhas para caber horizontalmente na largura
--definida para impressão
function util.paintBreakedString(areaWidth, x, initialY, text)
     --Text Width e Text Height de um caractere minúsculo
     local tw, th = canvas:measureText("a")

     --Estima quantos caracteres cabem dentro da largura
     --definida para a exibição de uma mensagem do Twitter 
     local charsByLine = math.floor(areaWidth / tw)
      -- print(text)
     --Quebra o texto em diversas linhas, 
     --gerando uma tabela onde cada item é uma linha que
     --foi quebrada. Isto é usado para que o texto seja
     --exibido sem sair da tela. 
     local textTable = util.breakString(text, charsByLine)
     local y = initialY
     --Percorre a tabela gerada a partir da quebra do texto 
     --em linhas, e imprime cada linha na tela 
     if textTable ~= nil then
      -- util.printable(textTable)
         for k, ln in pairs(textTable) do
            canvas:attrColor(255, 255, 255, 255)
            canvas:attrFont('Tiresias', 10)
            canvas:drawText(x, y, ln)
            y = y + th
            --print("---------------------"..ln)
        end
      end
end

---Desenha um texto na tela
--@param x Posição horizontal a ser impresso o texto
--@param y Posição vertical a ser impresso o texto
--@param text texto a ser desenhado
--@param fontName Nome da fonte a ser utilizada para imprimir o texto. Opcional
--@param fontSize Tamanho da fonte. Opcional
--@param fontColor Cor da fonte. Opcional
function util.paintText(x, y, text, fontName, fontSize, fontColor)
     if fontName and fontSize then
        canvas:attrFont(fontName, fontSize)
     end
     if fontColor then
        canvas:attrColor(fontColor)
     end
     
     --width e height do canvas
     local cw, ch = canvas:attrSize()
     canvas:drawText(x, y, text)     
end

---Verifica se um arquivo existe
--@param fileName Nome do arquivo a ser verificado
--@return Retorna true se o arquivo existir
function util.fileExists(fileName)
  local file = io.open(fileName)
  if file then
    io.close(file)
    return true
  else
    return false
  end
end

---Cria um arquivo com o conteúdo informado em text.
--Devido a função utilizar o módulo io, não disponível
--no Ginga, a mesma deve ser utilizada apenas
--para depuração, em ambientes de teste.
--Se o arquivo já existir, substitui.
--@param content Conteúdo a ser adicionado no arquivo
--@param fileName Nome do arquivo a ser gerado.
--@param boolean binaryFile Indica se o arquivo a ser salvo é binário ou não 
--@return Retorna true caso o arquivo seja salvo com sucesso.
function util.createFile(content, fileName, binaryFile)
    binaryFile = binaryFile or false
    local mode = "w+"
    if binaryFile then
       mode = "w+b"
    else
       mode = "w+"
    end
    local file, err = io.open(fileName, mode)
    if file == nil then
      return false
    else
      file:write(content)
      file:close()
      return true
    end
end

---Função para converter uma tabela para o formato URL-Encode,
--também chamado de Percent Encode, segundo RFC 3986.
--Fonte: http://www.lua.org/pil/20.3.html. Gerada a partir das funções
--escape e encode, gerando uma só.
--@param t Tabela contendo os pares param=value
--que representam os parâmetros a serem codificados para o formato URL-Encode,
--ou String contendo o texto a ser codificado.
--@return Retorna uma string codificada em URL-Encode
function util.urlEncode(t)
	  local function escape (s)
	    s = string.gsub(s, "([&=+%c])", function (c)
	          return string.format("%%%02X", string.byte(c))
	        end)
	    s = string.gsub(s, " ", "+")
 	    return s
 	  end

      if type(t) == "string" then
         return escape(t)
      else
	     local s = ""
	     for k,v in pairs(t) do
	       s = s .. "&" .. escape(k) .. "=" .. escape(v)
	     end
	     return string.sub(s, 2)     -- remove first `&'
      end
end    

--Conta o total de elementos em uma tabela indexada com chaves string,
--pois o operador # não funciona para obter o total de elementos de tais tabelas.
--@param Tabela a ser contato o total de elementos
--@return Retorna o total de elementos da tabela
function util.count(tb)
   local i = 0
   for k, v in pairs(tb) do
      i = i + 1
   end
   return i
end

---Verifica se uma tabela contém apenas um elemento
--@param tb Tabela ser verificada
--@return Retorna true caso a tabela contenha apenas um elemento.
function util.hasSingleElement(tb)
   --Para tabelas mais complexas, geradas a partir de um XML este código não funciona, 
   --congelando a aplicação.
   --local k=next(tb)
   --return k~=nil and next(tb,k)==nil

    local i = 0
    for k, v in pairs(tb) do
        i = i + 1
        if i > 1 then
           return false
        end
    end

    return i == 1    
end

--Obtém o primeiro elemento de uma tabela
--@param Tabela de onde deverá ser obtido o primeiro elemento
--@return Retorna o primeiro elemento da tabela
function util.getFirstElement(tb)
   if type(tb) == "table" then
       --O uso da função next não funciona para pegar o primeiro elemento. Trava aqui 
      --k, v = next(tb)
      --return v
      for k, v in pairs(tb) do
          return v
      end
   else
     return tb
   end
end

--Obtém a primeira chave de uma tabela
--@param Tabela de onde deverá ser obtido o primeiro elemento
--@return Retorna a primeira chave da tabela
function util.getFirstKey(tb)
   if type(tb) == "table" then
       --O uso da função next não funciona para pegar o primeiro elemento. Trava aqui 
      --k, v = next(tb)
      --return k
      for k, v in pairs(tb) do
          return k
      end
      return nil
   else
     return tb
   end
end

---Percorre uma tabela recursivamente. Se ela contém apenas um elemento,
--a tabela a qual ele pertence (a externa) é eliminada, ficando apenas a tabela interna,
--passando esta a ser a tabela principal. Repete isto até chegar no item mais interno da tabela.
--Assim, uma tabela como nivel1 = { nivel2 = nivel3 = {desc = "mouse", valor = 99}}
--se transforma em {desc="mouse", valor = 99}
--Outra tabela como nivel1 = { nivel2 = nivel3 = {pais = "Brasil"}}
--se transforma em pais = "Brasil", sem nenhuma tabela.
--@param tb Table lua gerada a partir de código XML
--@return Retorna a nova tabela simplificada. Se dentro de toda a estrutura
--da tabela original só existia um campo com valor, tal valor é retornado
--como uma variável simples.
function util.simplifyTable(tb)
   local tmp = tb
   while type(tmp) == "table" and util.hasSingleElement(tmp) do
      tmp = util.getFirstElement(tmp)
   end
   return tmp
end

---Cria uma co-rotina para execução de uma determinada função.
--@param f Função body a ser executada pela co-rotina
--@param ... Parâmetros adicionais que serão passados à função
--body da co-rotina, passada no parâmetro f.
function util.coroutineCreate(f, ...)
    coroutine.resume(coroutine.create(f), ...)
end

---Obtém o nome de um arquivo a partir de sua URL,
--seja esta um endereço na web ou um caminho de diretório local
--@param string url URL de onde obter o nome do arquivo
--@return string Retorna somente o nome do arquivo obtido da URL.
function util.getFileName(url)
  url = string.reverse(url)
  local i = string.find(url, "/")
  if i then
    url = string.sub(url, 1, i-1)
    url = string.reverse(url)
    return url
  else
    return ""
  end
end

---Quebra uma string em uma tabela (vetor) de strings.
--http://lua-users.org/wiki/SplitJoin
--@param string s String a ser dividida
--@param string sep Separador contido na string s que será usado para quebrá-la
--em várias strings
--@return table Tabela (vetor) contendo as strings quebradas a partir de s
function util.split(s, sep)
    local fields
    sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    s:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

---Parse boolean strings to boolean
--@param string str String booleano.
-- Aceita "true", "TRUE", "True" e "1" para true
-- Demais valores retornam false
--@return boolean
function util.parseStringBoolSafe(str)
    local b={
        ["true"]=true, ["TRUE"]=true, ["True"]=true, ["1"]=true,
        -- ["false"]=false, ["FALSE"]=false, ["False"]=false, ["0"]=false,
    }
    return b[str]
end

---Parse boolean strings to boolean
--@param string str String booleano.
-- Aceita "true", "TRUE", "True" e "1" para true
-- Aceita "false", "FALSE", "False" e "0" para false
-- Demais valores retornam um erro
--@return boolean |
function util.parseStringBoolOrError(str)
    if (str == "true"
       or str == "TRUE"
       or str == "True"
       or str == "1") then return true
    elseif (str == "false"
      or str == "FALSE"
      or str == "False"
      or str == "0") then return false
    else return error("invalid boolean string to parse")
    end
end

return util