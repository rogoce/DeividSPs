

--drop procedure sp_che0203;

create procedure sp_che0203(a_compania char(3),a_cod_banco char(3),a_cod_ctabanco char(4),a_ano_transac char(4),a_mes_transac char(2),a_estado char(2),a_fecha_final DATE
) returning DATE,char(2),char(10),char(200),dec(15,2),char(1);


define _fecha		   DATE;
define _tipo_docu	   char(2);
define _nodocmto	   char(10);
define _anombre        char(200);
define _monto		   dec(15,2);
define _estado         char(1);



SET ISOLATION TO DIRTY READ;

foreach
 select	 fecha,
         tipo_docu,
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
	and estado IN ('1','P')
ORDER BY fecha, tipo_docu, nodocmto
  
  

	return _fecha,
           _tipo_docu,
           _nodocmto,
           _anombre,
           _monto,
           _estado
		   with resume;

end foreach

end procedure
