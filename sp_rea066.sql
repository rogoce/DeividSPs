-- Procedimiento que disminuye la reserva del reclamo y la aumenta

-- Creado    : 22/09/2015 - Autor: Armando Moreno

drop procedure sp_rea066;

create procedure sp_rea066()
returning integer,
          char(50);

define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _reserva_cob			dec(16,2);

DEFINE _cod_cobertura   	CHAR(5);  
DEFINE _cod_cliente     	CHAR(10); 
DEFINE _numrecla        	CHAR(18); 

DEFINE _no_tranrec_char 	CHAR(10); 
DEFINE _no_tran_char    	CHAR(10); 

DEFINE _version		    	CHAR(2);
DEFINE _aplicacion	    	CHAR(3);
DEFINE _valor_parametro 	CHAR(20);
DEFINE _valor_parametro2	CHAR(20);
DEFINE _fecha_no_server  	DATE;
DEFINE _periodo_rec     	CHAR(7);  

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);
define _no_poliza           char(10);
define _reserva_actual      decimal(16,2);
define _cod_ramo            char(3);
define _no_reclamo          char(10);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

foreach

	select no_reclamo
	  into _no_reclamo
	  from rec_pen
	 where no_reclamo not in('02439',
'03269',
'03754',
'109307',
'110705',
'113849',
'114111',
'127527',
'128569',
'135703',
'14694',
'158248',
'15889',
'159607',
'160418',
'162767',
'164340',
'164549',
'166073',
'167403',
'16907',
'169233',
'17295',
'173020',
'176958',
'177564',
'18057',
'18066',
'18106',
'189292',
'190347',
'195031',
'195614',
'197073',
'198200',
'201980',
'204781',
'207117',
'207689',
'211247',
'212891',
'215242',
'216683',
'216800',
'217982',
'219481',
'220655',
'221594'
)
	 order by no_reclamo 

	call sp_rea064(_no_reclamo,'DEIVID') returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc;
	end if
	
end foreach
end

return 0, "Actualizacion Exitosa";

end procedure