# проверку на список черных машин либо на тотал сайз который превышает 2 ТБ
#

#Получаем список ВМ и выбираем нужные для миграции
$listVMs = Get-SCVirtualMachine | where {$_.HostName -like "*ucs*"} | select name, @{Name="memory";Expression={$_.memory*1mB}}, TotalSize, HostName | sort -Property TotalSize -Descending | Out-GridView -PassThru

#получаем список дисков стореджа
$disk = Get-SCStorageDisk | where {($_.VMHost -eq "hv02.co.volia.com") -and ($_.ClusterDisk -ne $null) -and ($_.ClusterDisk -notlike "*itCloud_cluster_whitness*")}

#Получаем список хостов в кластере, приводим всю память к байтам
$virtualhost = get-scvmhost |  where {$_.HostCluster -ne $null} | select name,@{Name="AvailableMemory";Expression={$_.AvailableMemory*1mB}}, TotalMemory

#------------------Создаем массивы для миграции ВМ---------------------------------------------
#----------------Обнуляем массывы разрешенных и запрещенных к миграции ВМ----------------------
$nonmigrateVMs = @()
$migrateVMs = @()

foreach ($listvm in $listVMs)
{
$maxdisksize = 0
#---------получаем размер дисков для каждой ВМ и суммируем их-------------------------------
$disksize = Get-SCVirtualHardDisk -VM $listvm.Name | select name, MaximumSize
#---------Сравниваем полученный размер с размером LUN---------------------------------------
$disksize.MaximumSize | foreach {$maxdisksize += $_}
    #
    if ($maxdisksize -gt 2199023255552)
        {
        $nonmigrateVMs += $listvm #---Машинки которые требуется мигрировать руками----------

        }
    Else
        {
        $migrateVMs += $listvm #---Машинки для миграции---

        }
}


#------------------блок расчет оперативной памяти доступной для переноса ВМ--------------------

#Суммируем требуемую ОЗУ для переносимых ВМ
$sumMemoryVM = 0
$migrateVMs.memory | foreach {$sumMemoryVM += $_}
$sumMemoryVMGB = $sumMemoryVM/1gb

#Ищем Хост с самым большим объемом памяти
$virtualhost = $virtualhost | Sort-Object -Property TotalMemory -Descending
$maxMemoryHost = $virtualhost[0].TotalMemory
$maxMemoryHostGB = $maxMemoryHost/1gb

#Количество резервируемой памяти, считаем так ОЗУ самого большого хоста плюс количество хостов умноженное на 4
$rezervmemory = $maxMemoryHost + ($virtualhost.count * (4 * 1gb))
$rezervmemoryGB = $rezervmemory/1gb

#Суммируем доступную память со всех хостов
$sumMemoryHost = 0
$virtualhost.AvailableMemory | foreach {$sumMemoryHost += $_}
$sumMemoryHost
$sumMemoryHostGB = $sumMemoryHost/1gb

<#
#Суммируем общую память со всех хостов ??? И зачем, а если у нас одна лине
$sumMemoryHosttotal = 0
$virtualhost.TotalMemory | foreach {$sumMemoryHostTotal += $_}
$sumMemoryHostTotal
$sumMemoryHostTotalgb = $sumMemoryHostTotal/1gb
#>

#проверяем разницу должно быть Из доступной отнимаем сумму резервная память + требуемая память. НЕ должно быть меньше 0
$TestMem = $sumMemoryHost - $rezervmemory - $sumMemoryVM
$testMemGB = $testMem/1gb

if ($TestMem -gt 0)
{
    


#------------------------------------------------------------------------------------------------

foreach ($listvm in $migrateVMs)
    {
#Сортируем дисковый массив от самого свободного и сохраняем массив
$disk = $disk | select ClusterDisk, Capacity, AvailableCapacity  | Sort-Object -Property AvailableCapacity -Descending  | select ClusterDisk, Capacity, AvailableCapacity 
# Отнимаем от свободного места на сторедже расчетное пространство для виртуальной машины

# ????? -------проверку на ошибку если размер ВМ более чем размер ЛУНА и запись ошибки
$disk[0].AvailableCapacity = $disk[0].AvailableCapacity - $listVM.TotalSize


#сортируем по убыванию доступной памяти
$virtualhost = $virtualhost | Sort-Object -Property AvailableMemory -Descending
# Отнимаем требуемую оперативную память для ВМ от доступной оперативной памяти ВМ Хоста
$virtualhost[0].AvailableMemory = $virtualhost[0].AvailableMemory - $listvm.memory
  
  
 # Собираем путь для расположения ВМ
 $patch = "C:\ClusterStorage\" + $disk[0].ClusterDisk
 #Move-SCVirtualMachine -VM $listVM.Name -VMHost $virtualhost[0].name -Path $patch -HighlyAvailable $true -RunAsynchronously -UseDiffDiskOptimization
    }
}
Else
{
Write-host "----------------------------------------------" -BackgroundColor Red
write-host "Не достаточно оперативной памяти для миграции ВМ" -ForegroundColor Red
write-host "необходимо уменьшить память на " $testMemGB "ГБ" -ForegroundColor Red
Write-host "----------------------------------------------" -BackgroundColor Red
exit
}




$nonmigrate = $nonmigrateVMs | ft name, totalsize -AutoSize
Write-host "----------------------------------------------" -BackgroundColor Red
Write-host "Машины не мигрированы, превышен допустимый размер диска"  -ForegroundColor "red"
Write-host "----------------------------------------------" -BackgroundColor Red
Write-Output $nonmigrate
Write-host "----------------------------------------------" -BackgroundColor Red

$migrate = $migrateVMs | ft name, totalsize -AutoSize
Write-host "----------------------------------------------" -BackgroundColor green
Write-host "Машины запущенные на мигриацию"  -foregroundcolor "green"
Write-host "----------------------------------------------" -BackgroundColor green
Write-Output $migrate
Write-host "----------------------------------------------" -BackgroundColor green