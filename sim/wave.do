onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tbneuralnet/Clk
add wave -noupdate /tbneuralnet/nRst
add wave -noupdate -divider {Control Signals}
add wave -noupdate -color Yellow /tbneuralnet/Start
add wave -noupdate -color Yellow /tbneuralnet/Learn
add wave -noupdate -color Yellow /tbneuralnet/FinishedForward
add wave -noupdate -color Yellow /tbneuralnet/FinishedBackward
add wave -noupdate -color Yellow /tbneuralnet/FinishedAll
add wave -noupdate -divider {Error Measurement}
add wave -noupdate -color Red /tbneuralnet/SqrtError
add wave -noupdate -color Red /tbneuralnet/RecentAvgError
add wave -noupdate -divider {Neural Net Input/Output}
add wave -noupdate -color {Cornflower Blue} -radix sfixed /tbneuralnet/Inputs
add wave -noupdate -color {Cornflower Blue} -radix sfixed /tbneuralnet/Targets
add wave -noupdate -color {Cornflower Blue} -radix sfixed /tbneuralnet/Outputs
add wave -noupdate -color {Cornflower Blue} /tbneuralnet/Outputs_Binary
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {56001 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 204
configure wave -valuecolwidth 125
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {188668 ns}
