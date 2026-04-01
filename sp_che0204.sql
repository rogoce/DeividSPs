

drop procedure sp_che0204;

create procedure sp_che0204(a_compania char(3),a_cod_banco char(3),a_cod_ctabanco char(4),a_ano_transac char(4),a_mes_transac char(2),a_estado char(2),a_fecha_final DATE
) returning DATE,char(2),char(10),char(200),dec(15,2),char(1);

define _fecha		   DATE;
define _tipo_docu	   char(2);
define _nodocmto	   char(10);
define _anombre        char(200);
define _monto		   dec(15,2);
define _estado         char(1);

SET ISOLATION TO DIRTY READ;

If a_estado = "1" Then

foreach
 select	 fecha,
         tipo_proceso,
         nodocmto,
         anombre,
         monto,
         estado
   into  _fecha,
         _tipo_docu,
         _nodocmto,
         _anombre,
         _monto,
         _estado
   from	bcocirc
  where compania       = a_compania
    and cod_banco    = a_cod_banco
	and cod_ctabanco     = a_cod_ctabanco
	and fecha  <= a_fecha_final
	AND estado IN ('0','C','P') 
	AND ano_transac IS NULL
	 OR ((ano_transac = a_ano_transac AND 
	      mes_transac = a_mes_transac)
	AND cod_banco     = a_cod_banco
	AND cod_ctabanco  = a_cod_ctabanco)
ORDER BY fecha desc, tipo_proceso desc, nodocmto asc
  
  	 

	return _fecha,
           _tipo_docu,
           _nodocmto,
           _anombre,
           _monto,
           _estado
		   with resume;

end foreach

Else

foreach
 select	 fecha,
         tipo_proceso,
         nodocmto,
         anombre,
         monto,
         estado
   into  _fecha,
         _tipo_docu,
         _nodocmto,
         _anombre,
         _monto,
         _estado
   from	bcocirc
  where compania       = a_compania
    and cod_banco    = a_cod_banco
	and cod_ctabanco     = a_cod_ctabanco
	and fecha  <= a_fecha_final
	and ano_transac IS NULL
	and estado IN ('0','P')
ORDER BY fecha desc, tipo_proceso desc, nodocmto asc
  
  

	return _fecha,
           _tipo_docu,
           _nodocmto,
           _anombre,
           _monto,
           _estado
		   with resume;

end foreach

End If

end procedure
