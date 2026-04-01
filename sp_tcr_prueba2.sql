
drop procedure sp_tcr_prueba2;
create procedure "informix".sp_tcr_prueba2()
returning	char(19),
            char(7),
            char(20),
			varchar(100),
			decimal(16,2),
			smallint;
		   		  																  

define _no_documento		char(20);
define _monto       dec(16,2);
define _fecha_exp   char(7);
define _desc_remesa varchar(100);
define _no_tarjeta  char(19);
define _dia         smallint;


set isolation to dirty read;

--SET DEBUG FILE TO "sp_cob275.trc";
--TRACE ON;
{
foreach
	select doc_remesa,
	       desc_remesa,
		   sum(monto)
   	  into _no_documento,
	       _desc_remesa,
		   _monto
	  from cobredet
	 where no_remesa in('1289002','1289497')
	 group by doc_remesa,desc_remesa
	having count(doc_remesa) > 1
	 order by doc_remesa
    
	select no_tarjeta,dia
	  into _no_tarjeta,_dia
	  from cobtacre
	 where no_documento = _no_documento;
	 
	select fecha_exp
	  into _fecha_exp
	  from cobtahab
	 where no_tarjeta = _no_tarjeta;
    	
	return _no_tarjeta,_fecha_exp,_no_documento,_desc_remesa,_monto,_dia with resume;
	
end foreach
}
foreach
	select doc_remesa,
		   desc_remesa,
		   monto
	  into _no_documento,
	       _desc_remesa,
		   _monto
	  from cobredet
	 where doc_remesa not in(select doc_remesa
					  from cobredet
					  where no_remesa = '1289002')
	and no_remesa = '1289497'
    
	select no_tarjeta,dia
	  into _no_tarjeta,_dia
	  from cobtacre
	 where no_documento = _no_documento;
	 
	select fecha_exp
	  into _fecha_exp
	  from cobtahab
	 where no_tarjeta = _no_tarjeta;
    	
	return _no_tarjeta,_fecha_exp,_no_documento,_desc_remesa,_monto,_dia with resume;
	
end foreach

end procedure
