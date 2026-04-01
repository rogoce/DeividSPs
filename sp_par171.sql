drop procedure sp_par171;

create procedure "informix".sp_par171()

define _no_documento	char(20);

foreach
 select poliza
   into _no_documento
   from intins

	update emipomae
	   set cod_grupo    = "01006"
	 where no_documento = _no_documento
	   and periodo      >= "2005-10";

end foreach

end procedure