onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tbneuralnet/Clk
add wave -noupdate /tbneuralnet/nRst
add wave -noupdate -divider {Control Signals}
add wave -noupdate -color Yellow /tbneuralnet/Start
add wave -noupdate -color Yellow /tbneuralnet/Learn
add wave -noupdate -color Yellow /tbneuralnet/Finished
add wave -noupdate -divider {Error Measurement}
add wave -noupdate -color Red -radix sfixed /tbneuralnet/Error
add wave -noupdate -color Red /tbneuralnet/SqrtError
add wave -noupdate -color Red /tbneuralnet/RecentAvgError
add wave -noupdate -divider {Neural Net Input/Output}
add wave -noupdate -color {Cornflower Blue} /tbneuralnet/Inputs
add wave -noupdate -color {Cornflower Blue} /tbneuralnet/Targets
add wave -noupdate -color {Cornflower Blue} /tbneuralnet/Outputs
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8514158982 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {8458646616 ps} {8656974936 ps}
