-- Insertando 
-- Creado    : 15/07/2010 - Autor: Amado Perez M.
-- Modificado: 15/07/2010 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

drop procedure sp_pro521;

create procedure sp_pro521(
    a_no_documento	char(20),
    a_abogado		char(3))

returning smallint,
		  char(25);

define _cod_asegurado		char(10);
define _no_poliza			char(10);
define _cod_formapag		char(3);
define _cod_subramo			char(3);
define _cod_perpago			char(3);
define _cod_producto_new	char(5);
define _cod_producto		char(5);
define _cod_grupo			char(5);
define _prima_asegurado		dec(16,2);
define _error				smallint;
define _fecha_periodo		date;
DEFINE _mes_contable      CHAR(2);
DEFINE _ano_contable      CHAR(4);
DEFINE _periodo           CHAR(7);
DEFINE _saldo_tot         DEC(16,2);
DEFINE _por_vencer_tot    DEC(16,2);
DEFINE _exigible_tot      DEC(16,2);
DEFINE _corriente_tot     DEC(16,2);
DEFINE _monto_30_tot      DEC(16,2);
DEFINE _monto_60_tot      DEC(16,2);
DEFINE _monto_90_tot      DEC(16,2);
define _generar_endoso    smallint;
define _cant     		  smallint;
define _estatus_poliza    smallint;

--set debug file to "sp_pro172.trc";

set isolation to dirty read;

LET _fecha_periodo = CURRENT;

LET _ano_contable = YEAR(_fecha_periodo);

IF MONTH(_fecha_periodo) < 10 THEN
	LET _mes_contable = '0' || MONTH(_fecha_periodo);
ELSE
	LET _mes_contable = MONTH(_fecha_periodo);
END IF

LET _periodo = _ano_contable || '-' || _mes_contable;
 
call sp_sis21(a_no_documento) returning _no_poliza;
  
select estatus_poliza  
  into _estatus_poliza
  from emipomae
 where no_poliza = _no_poliza;

CALL sp_cob33(
	 '001',
	 '001',	
	 a_no_documento,
	 _periodo,
	 _fecha_periodo
	 ) RETURNING _por_vencer_tot,       
				 _exigible_tot,         
				 _corriente_tot,        
				 _monto_30_tot,         
				 _monto_60_tot,         
				 _monto_90_tot,
				 _saldo_tot;         

let _generar_endoso = 0;
let _cant           = 0;

if _estatus_poliza = 2 then
   select count(*)
     into _cant
	 from endedmae
	where no_poliza = _no_poliza
	  and cod_endomov = '002'
	  and cod_tipocalc = '001';

   if _cant > 0 then
		let _generar_endoso = 1;
   end if
end if

set lock mode to wait;

begin
on exception set _error    		
--	if _error = -268 or _error = -239 then 
--	else
 		return _error, "Error al Actualizar";         
--	end if
end exception 


insert into tmpoutleg(
		no_documento,
		no_poliza,
		prima,
		cod_abogado,
		status_poliza,
		generar_endoso
		)
values	(
		a_no_documento,
		_no_poliza,
		_saldo_tot,  
		a_abogado,           
		_estatus_poliza,    
		_generar_endoso
		);

end
return 0, "Actualizacion Exitosa";
end procedure;