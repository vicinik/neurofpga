onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tbneuralnet/Clk
add wave -noupdate /tbneuralnet/nRst
add wave -noupdate /tbneuralnet/Start
add wave -noupdate /tbneuralnet/Learn
add wave -noupdate /tbneuralnet/Finished
add wave -noupdate -radix sfixed /tbneuralnet/Error
add wave -noupdate /tbneuralnet/Inputs
add wave -noupdate /tbneuralnet/Outputs
add wave -noupdate /tbneuralnet/Targets
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {99996467 ps} 0}
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
WaveRestoreZoom {0 ps} {198328320 ps}
