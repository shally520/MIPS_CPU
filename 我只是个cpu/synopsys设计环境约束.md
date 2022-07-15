为了从DC得到最佳结果，设计人员应通过描述设计环境、目标和设计规则来系统地约束其设计。约束可包括时序和/或面积信息，通常由设计规范给出。DC运用这些约束条件进行综合并且试图优化设计达到最终目标。

## 设计环境
假设设计已经完成了划分、编码和仿真，下一步就是要描述设计环境，这一步需要为设计定义工艺参数、I/O端口属性和线载模型。下图说明了用于描述设计环境的基本DC命令。

**set_min_library**是DC98版本引进的一个新命令，该命令允许用户同时指定最坏情况和最佳情况的库。
```
set_min_library <max library filename> -min_version <min library filenames>
```
上一命令可用于修正保持时间违例或用于合理优化。

**set_operating_conditions**描述了设计的工艺、电压及温度条件。Synopsys库包含这些条件的描述，通常描述为WORST、TYPICAL和BEST情况。WORST情况工作条件通常用于布图前综合阶段，因此以最大建立时间优化设计。BEST情况通常用于修正保持时间违例。
```
set_operating_conditions <name of operating conditions>
```
有可能用WORST和BEST情况同时进行优化设计。如下所示，在上述命令中使用-min和-max选项进行优化。这对修正设计保持时间违例十分有用。
```
set_operating_conditions -min BEST -max WORST
```
**set_wire_load_mode**命令用来为DC提供估计的线载信息，反过来DC使用线载信息把连线延迟建模为负载的函数。通常Synopsys工艺库中列出了许多线载模型，每个模型代表一个特定大小的模块。
```
set_wire_load_mode -name <wire-load model>
```
set_wire_load_mode定义了三种同建模连线负载相关的模式，分别为top、enclosed和segmented。

top模式定义层次中的所有连线将继承和顶层模块同样的线载模型。exclosed指定所有连线（属于子模块的）将继承完全包含该子模块的模块线载模型。例如设计者综合完全被模块A包含的子模块B和C，则子模块B和C会继承为模块A定义的线载模型。segmented用于跨越层次边界的连线。在上例中，子模块B和C继承特定于他们的线载模型，而子模块B和C间的连线（在模块A）会继承为模块A指定的线载模型。
```
set_wire_load_mode <top | enclosed | segmented>
```
**set_drive**和**set_drving_cell**用于模块的输入端口。set_drive命令用于指定输入端口的驱动强度，主要用于模块建模或芯片端口外驱动电阻。0值表示最高驱动强度且通常用于时钟端口。set_driving_cell用于对输入端口驱动单元的驱动电阻进行建模，这一命令将驱动单元的名称作为其参数并将驱动单元的所有设计约束应用于模块的输入端口。

**set_load**将工艺库中定义的单位上的容性负载设置到设计的指定连线或端口。它主要用于在布图前综合过程中设置模块输出端口的容性负载和往连线上反标注布图后提取的电容信息。

**设计规则**或**DRC**由set_max_transition、set_max_fanout和set_max_capacitance命令组成。这些规则通常在工艺库中设置并且由工艺参数决定。DRC命令可用于输入端口、输出端口或current_design，此外，也可以使用这些命令修改参数：
```
set_max_transition

set_max_capacitance

set_max_fanout
```
https://mp.weixin.qq.com/s?__biz=Mzg4OTIwNzE4Mg==&mid=2247483754&idx=1&sn=cf8dc9f5649ecdf7a769d576a1339be5&chksm=cfee218bf899a89d6c7442adbf16c7d7093517d4dc7c0ff7913119ea3b7aca82741dd9e1fb86&token=1433471869&lang=zh_CN#rd

## 设计约束
而设计约束描述了设计目标，它们可包括时序或面积约束。不实际的规范会导致面积增大、功耗增加和/或时序恶化，所以设计人员必须指定实际的约束。

**create_clock**命令用于定义有特定周期和波形的时钟对象。-period选项定义时钟周期，而-waveform选项控制时钟的占空比和起始边沿。这个命令用于引脚或端口对象类型。

下例指定端口CLK为“时钟”类型，其周期为40ns，占空比为50%。时钟正边沿开始于0ms，下降边沿发生在20ns。通过改变下降沿值，可改变时钟占空比。
```
create_clock -period 40 -waveform [list 0 20] CLK
```
**create_generated_clock**命令用于设计内部生成的时钟，可以描述作为主时钟函数的分频/倍频时钟。
```
create_generated_clock -name <clock name>

-source <clock source>

-divide_by <factor> | multiply_by <factor>
```
**set_dont_touch_network**是一个非常有用的命令，通常用于时钟网络的复位。这个命令用于在时钟引脚或端口上设置dont_touch属性。注意设置这一属性也会阻止DC为满足DRC而缓冲连线。此外，任何与被设置为“dont_touch”的连线相接触的门也将继承dont_touch属性。

**set_dont_touch**用于在current_design、单元、引用或连线上设置dont_touch属性。这一命令经常用于模块的层次化编译过程中，它也能用于阻止DC推断工艺库中的某种类型单元。

例：
```
set_dont_touch current_design

set_dont_touch [get_cells subs]

set_dont_touch [get_nets gated_rst]
```
**set_dont_use**命令通常设置在.synopsys_dc.setup环境文件中，这一命令有助于从工艺库中剔除用户不愿DC推断的某类单元。

**set_input_delay**指定相对于时钟的信号输入到达时间。它用于输入端口，指定在时钟沿后数据稳定所需的时间。设计的时序规范通常包括这样的信息，如输入信号的建立/保持时间要求。如果给定设计的顶层时序规范，也可通过用自顶向下的编译方法或设计预算方法提取出子模块的这些信息。
```
dc_shell > set_input_delay -max 23.0 -clock CLK {data_in}

dc_shell > set_input_delay -min 0.0 -clock CLK {data_in}
```
在下图中，相对于占空比为50%，周期为30ns的时钟信号CLK，为信号data_in指定了23ns的最大输入延时约束和0ns的最小输入延时约束。换言之，输入信号data_in的建立时间要求为7ns，而保持时间要求为0ns。


**set_output_delay**命令用于在输出端口定义在时钟边沿到来之前数据有效所需时间。
```
dc_shell > set_output_delay -max 19.0 -clock CLK {data_out}
```

**set_clock_latency**命令用于定义在综合时估计的时钟插入延迟，这主要用于布图前综合和时序分析。所估计的延迟值是时钟树网络插入（在布图阶段）产生的延迟的近似值。
```
dc_shell > set_clock_latency 3.0 [get_clocks CLK]
```
**set_clock_uncertainty**命令让用户定义时钟扭曲（clock skew）信息。
```
dc_shell > set_clock_uncertainty -setup 0.5 -hold 0.23 [get_clocks CLK]
```
**set_clock_transition**命令用于进行布图前综合和时序分析。这个命令使DC对时钟端口或引脚使用指定的转换值。

**set_propagated_clock**用于当设计已完成时钟树网络插入的布图后阶段。在这种情况下，将使用传统的延迟计算方法求出延时。

## 高级约束
以上和之前的一节主要介绍的是常用约束。下面介绍的是额外的一些设计约束，包括指定虚假路径、多周期路径、最大和最小延迟等。此外，还讨论了为额外优化而组合时序关键路径的过程。

**set_false_path**用于指示DC忽视某一路径的时序或优化。确定设计中的虚假路径是关键，否则会迫使DC优化所有路径，关键时序路径可能受到不利的影响。

用于这一命令的有效起点和终点分别是输入端口或时序元件的时钟引脚和输出端口或时序元件的数据引脚。另外可使用-through进一步明确某一路径。
```
dc_shell > set_false_path -from in1 -through U1/Z -to out1
```
**set_multicycle_path**用于告知DC通过某一路径到达其终点所需的时钟周期数。DC自动假定所有路径都是单周期路径，同时不必为了获取时序而试图优化多周期段。

**set_max_delay**定义某一路径按照时间单位所需的最大延迟。通常它用于只包含组合逻辑的模块。然而，它也用于约束多个具有不同频率时钟驱动的模块。

虽然Synopsys建议每个模块只定义一个时钟，而在某些情况下一个模块可包含多个时钟，每个时钟具有不同的频率。为了约束这种模块，通常可用create_clock和set_dont_touch_network命令来定义模块中的所有时钟。然而信号相对于每个时钟的输入延时赋值会变得很冗长。为避免这一情况，另一种方法就是用通用的方法定义第一个时钟，而通过set_max_delay命令约束其他时钟：
```
dc_shell > set_max_delay 0 -from CLK2 -to [all_registers -clock_pins]
```
**set_min_delay**是与set_max_delay相对的命令，它用于定义某一路径按照时间单位所需的最小延迟。
```
dc_shell > set_min_delay 3 -from [all_inputs] -to [all_outputs]
```
**group_path**命令用于将设计中的时序关键路径绑定到一起以进行代价函数计算。组合能使组合路径优先于其他路径。这一命令有不同的选项，包括关键范围和权重的规范。
```
dc_shell > group_path -to [list out1 out2] -name group1
```
——添加太多组合对编译时间有显著的影响，因此只作为最后的手段使用；

——这一命令有可能增加设计中最差违例路径的延迟，这是由于DC使设计中的组合路径优先于其他路径。为改善整个代价函数，DC将尽力优化组合路径，然而可能恶化另一组的最差违例的时序。

https://zhuanlan.zhihu.com/p/72051232