$pdf_mode = 4;
@default_files = ('index.tex');
$out_dir = 'output';
$pdf_previewer = "zathura %O %S";
$lualatex = 'lualatex  %O  --shell-escape %S';

system("mkdir -p figures");
system("mkdir -p output/figures");
system("mkdir -p output/chapters");


add_cus_dep('idx', 'ind', 0, 'makeindex');
sub makeindex{
  system("makeindex \"$_[0].idx\"");
}

add_cus_dep('glo', 'gls', 0, 'makeglossaries');
add_cus_dep('acn', 'acr', 0, 'makeglossaries');
add_cus_dep('slo', 'sls', 0, 'makeglossaries');
sub makeglossaries {
  my ($base_name, $path) = fileparse( $_[0] );
  return system "makeglossaries -d '$path' '$base_name'";
}
