-- Procedimiento que cierra la reserva del reclamo

-- Creado    : 27/06/2008 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_rec158b;
create procedure sp_rec158b()

returning	integer,
			char(50);

define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _reserva_cob			dec(16,2);

DEFINE _cod_cobertura   	CHAR(5);  
DEFINE _cod_cliente     	CHAR(10); 
DEFINE _numrecla        	CHAR(18); 

DEFINE _no_reclamo		CHAR(10); 
DEFINE _no_tran_char    	CHAR(10); 

DEFINE _version		    	CHAR(2);
DEFINE _aplicacion	    	CHAR(3);
DEFINE _cod_tipotran    	CHAR(3);
DEFINE _estatus_reclamo    	CHAR(1);
DEFINE _valor_parametro 	CHAR(20);
DEFINE _valor_parametro2	CHAR(20);
DEFINE _fecha_ult_trx	  	DATE;
DEFINE _fecha_no_server  	DATE;
DEFINE _periodo_rec     	CHAR(7);  

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);
define _no_poliza           char(10);
define _reserva_actual      decimal(16,2);
define _cod_ramo            char(3);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception
let _reserva_actual = 0;

foreach
	select first 500 rec.numrecla,rec.no_reclamo,max(trx.fecha),sum(variacion)
	  into _numrecla,_no_reclamo,_fecha_ult_trx,_reserva_actual
	  from recrcmae rec
	 inner join rectrmae trx on trx.no_reclamo = rec.no_reclamo and trx.actualizado = 1
	 where rec.numrecla in ('18-0824-11014-01',
'18-0623-10882-01',
'18-1024-13818-01',
'18-1024-13992-01',
'18-1024-14240-01',
'18-1024-13491-01',
'18-1024-13354-01',
'18-0724-10000-01',
'18-0824-10642-01',
'18-0724-09313-01',
'18-0724-10065-01',
'18-0824-11598-01',
'18-1024-13495-01',
'18-1024-13588-01',
'18-1024-13929-01',
'18-1024-13434-01',
'18-1024-13751-01',
'18-0924-13252-01',
'18-0324-02896-01',
'18-0724-09983-01',
'18-0924-13270-01',
'18-1024-13435-01',
'18-0724-09572-01',
'18-1024-14195-01',
'18-1024-13757-01',
'18-0924-12264-01',
'18-0924-12929-01',
'18-0924-12722-01',
'18-1024-13548-01',
'18-1223-20304-01',
'18-0724-09795-01',
'18-0924-12944-01',
'18-1024-13720-01',
'18-0524-07275-01',
'18-1024-14272-01',
'18-1024-14551-01',
'18-1024-13699-01',
'18-1209-21825-01',
'18-1024-14102-01',
'18-0924-12060-01',
'18-0721-04804-01',
'18-0124-01480-01',
'18-1024-13358-01',
'18-1024-13606-01',
'18-1024-14093-01',
'18-1024-14299-01',
'18-1024-14422-01',
'18-1024-13898-01',
'18-1024-13467-01',
'18-0924-12747-01',
'18-1024-13902-01',
'18-1024-14597-01',
'18-1024-13875-01',
'18-1024-14224-01',
'18-1024-13547-01',
'18-1024-13426-01',
'18-0722-05677-01',
'18-1024-13904-01',
'18-1024-13544-01',
'18-1024-13577-01',
'18-1024-13590-01',
'18-1024-13591-01',
'18-1024-13592-01',
'18-1024-13594-01',
'18-1024-13643-01',
'18-1024-13675-01',
'18-1024-13710-01',
'18-1024-13777-01',
'18-1024-13825-01',
'18-1024-13931-01',
'18-1024-13933-01',
'18-1024-13934-01',
'18-1024-13951-01',
'18-1024-13987-01',
'18-1024-13989-01',
'18-1024-13995-01',
'18-1024-14167-01',
'18-1024-14202-01',
'18-1024-14262-01',
'18-1024-14327-01',
'18-1024-14347-01',
'18-1024-14402-01',
'18-1024-14409-01',
'18-1024-14410-01',
'18-1024-14411-01',
'18-1024-14416-01',
'18-1024-14433-01',
'18-1024-14434-01',
'18-1024-14435-01',
'18-1024-14500-01',
'18-1024-14520-01',
'18-1024-14574-01',
'18-1024-14583-01',
'18-1024-14584-01',
'18-1024-13685-01',
'18-1024-13568-01',
'18-0923-15407-01',
'18-0924-13037-01',
'18-1024-14244-01',
'18-1024-14415-01',
'18-0924-12237-01',
'18-1024-14400-01',
'18-0924-13029-01',
'18-1024-13812-01',
'18-1024-13746-01')
	group by 1,2
having sum(variacion) > 0

call sp_rec158a(_no_reclamo,_reserva_actual) returning _error,_error_desc; 

return _error,_error_desc with resume;

end foreach

return 0, "Actualizacion Exitosa";
end
end procedure 