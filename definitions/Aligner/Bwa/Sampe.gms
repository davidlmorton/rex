tool Tool::Aligner::Bwa::Sampe

inputs
File::AlignerIndex::Bwa alignment_index
File::Sai first_sai
File::Sai second_sai
File::Bam::Unaligned::Paired unaligned_bam
Integer::Bwa::Sampe::MaxInsertSize max_insert_size
PROCESS process_

outputs
File::Sam::Aligned output_file
