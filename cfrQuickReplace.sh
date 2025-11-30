#!/bin/bash
tmpFile=$HOME/.tmpFile # промежуточный файл, в него построчно копируются все строки не содержащие паттерн
                       # как только найдена будет строка содержащая паттерн она будет модифицирована
                       # согласно сценария, а затем дописана в tmpFile
                       # при удачном завершении основного сценария input_file копируется для сохранности как
                       # резервный файл, а tmpFile замещает его

input_file=$1  # файл КОНФИГУРАЦИИ в первом аргументе, который подвергается редактированию одного параметра, после окончания
               # работы скрипта файл либо замещается редактированной версией, либо выдается ошибка
pattern=$2     # параметр конфигурации значение которого подвергается редактированию
newValue=$3    # новое значение параметра pattern
oldValue=''    # старое значение если есть будет перемещено за знак # c пометкой oldValue
#Флаги скрипта
disabledOptionFlag=false        #во время анализа строки содержащий pattern будет выяснено
                                #активна ли опция, либо она закоментирована знаком #
patternAvailabilityFlag=false   #флаг устанавливается во время анализа и указывает доступен ли параметр, иными словами
                                #укладывается ли найденая строка в шаблон \# || [[:space:]]* $pattern...
equalSignAvailabilityFlag=false # флаг устанавливается во время анализа и указывает на присутствие после параметра знака равно '='

quotesAvailabilityFlag=false    #флаг устанавливается во время анализа и указывает на то что значение параметра заключено в одинарные ковычки

oldValueAvailabilityFlag=false  #флаг устанавливается во время анализа и указывает на то что в строке присутсвует старое значение

comentAvailabilityFlag=false    #флаг устанавливается во время анализа и указывает на присутствие коментария после значения




if [ -z "$input_file" ] || [  -z "$pattern"  ] || [ -z "$newValue" ]; then
  echo -e 'отсутствует аргумент \n  cfrQuickReplace <ФАЙЛ КОНФИГУРАЦИИ> <ИСКОМЫЙ ПАРАМЕТР> <НОВОЕ ЗНАЧЕНИЕ> '
  exit 0
fi

if [ ! -f $input_file ]; then
    echo "Файл $input_file отсутствует"
    exit 0
fi
lenPattern=${#pattern}

if [ $lenPattern -gt 30 ]; then
  echo "превышена ожидаемая длина строки <ИСКОМЫЙ ПАРАМЕТР> max 30 символов"
  exit 0
fi
lenNewValue=${#newValue}
if [ $lenNewValue -gt 60 ]; then
  echo "превышена ожидаемая длина строки <НОВОЕ ЗНАЧЕНИЕ> max 60 символов"
  exit 0
fi

if [ -f $tmpFile ]; then
    #echo "Файл $tmpFile существует"
    rm -v $tmpFile
fi

while IFS= read -r line; do
    if [[ "$line" == *"$pattern"* ]];
        then
          echo "228 $line"
          #if [[ "$line" =~ \#[[:space:]]*$pattern[[:space:]]*=[[:space:]]*\'([^\']+)\'[[:space:]]*\#([^\']+) ]];
          if [[ "$line" =~  [[:space:]]*\#[[:space:]]*$pattern ]];
            then
              disabledOptionFlag=true
              echo "параметр закоментирован"
            else
              disabledOptionFlag=false
          fi
          if [[ "$line" =~ [[:space:]]*\#*[[:space:]]*$pattern ]];
            then
              patternAvailabilityFlag=true
            else
              echo "местонахождения параметра не соответствует заданному шаблону"
              patternAvailabilityFlag=false
              continue
          fi
          if [[ "$line" =~ [[:space:]]*\#*[[:space:]]*$pattern[[:space:]]*= ]];
            then
              equalSignAvailabilityFlag=true
              echo "знак равно после параметра"
            else
              equalSignAvailabilityFlag=false
          fi
          if [[ "$line" =~ [[:space:]]*\#*[[:space:]]*$pattern[[:space:]]*=*[[:space:]]*\'([^\']+)\' ]];
            then
              quotesAvailabilityFlag=true
            else
              quotesAvailabilityFlag=false
          fi
          if [[ "$line" =~ [[:space:]]*\#*[[:space:]]*$pattern[[:space:]]*=*[[:space:]]*\'([^\']+)\' ]];
            then
              comentAvailabilityFlag=true
            else
              comentAvailabilityFlag=false
          fi



        else
          echo $line >> $tmpFile
    fi


done < "$input_file"
if [ -f $tmpFile ]; then
    echo "Конец программы"
    #rm -v $tmpFile
fi
