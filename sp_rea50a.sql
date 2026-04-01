--- crear saldos iniciales
--- Creado 13/09/2022 por Henry 
drop procedure sp_rea50a;
create procedure "informix".sp_rea50a(a_contrato char(2), a_anio char(10), a_trimestre integer)
returning char(9) as anio,
		 integer as trimestre,
		 char(3) as reasegurador,
		 char(2) as contrato,
		 dec(16,2) as saldo_inicial,
		 dec(16,2) as saldo_final,
		 dec(16,2) as saldo_trim,
		 varchar(100) as n_reasegurador;
begin


define _error			integer;
define _error_isam		integer;
define _error_desc		varchar(100);
define _contrato			char(2);
define _anio_reas			char(9);
define _trim_reas			integer;
define  _cod_coasegur		char(3);
define _saldo_inicial		dec(16,2);
define _saldo_final			dec(16,2);
define _saldo_trim			dec(16,2);
define _nom_reasegurador    varchar(100);


on exception set _error, _error_isam, _error_desc
   return '',_error,'','',0,0,0,_error_desc;
end exception

set isolation to dirty read;

foreach			   
  SELECT reaestct1.ano,   
         reaestct1.trimestre,   
         reaestct1.reasegurador,   
         reaestct1.contrato,   
         reaestct1.saldo_inicial,   
         reaestct1.saldo_final,   
         reaestct1.saldo_trim  
	into _anio_reas,
		 _trim_reas,
		 _cod_coasegur,
		 _contrato,
		 _saldo_inicial,
		 _saldo_final,
		 _saldo_trim
    FROM reaestct1  
   WHERE ( reaestct1.contrato = a_contrato ) AND  
         ( trim(reaestct1.ano) = a_anio ) AND  
         ( reaestct1.trimestre = a_trimestre )    
		 
	select nombre
	  into _nom_reasegurador
	  from emicoase
	 where cod_coasegur = _cod_coasegur;		 

return _anio_reas,
		 _trim_reas,
		 _cod_coasegur,
		 _contrato,
		 _saldo_inicial,
		 _saldo_final,
		 _saldo_trim,
		 _nom_reasegurador
    	   with resume;

end foreach
end
--return 0,'Realizado con Exito';
end procedure;
