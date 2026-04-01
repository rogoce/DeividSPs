-- Procedure que arregla los pagos mal calculados de prima e impuesto de la sucursal de chiriqui

drop procedure sp_cob209;

create procedure sp_cob209()
returning integer,
          char(50),
		  char(10);

define a_no_remesa		char(10);
define _null			char(1);
define _fecha			date;
define _renglon			smallint;
define _periodo			char(7);

define _no_remesa_error	char(10);
define _renglon_error	smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

begin work;

begin
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, _error_desc, _error_isam;
end exception

let a_no_remesa = sp_sis13("001", 'COB', '02', 'par_no_remesa');
let _null = null;

SELECT fecha
  INTO _fecha
  FROM cobremae
 WHERE no_remesa = a_no_remesa;

IF _fecha IS NOT NULL THEN
	RETURN 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualice Nuevamente ...', a_no_remesa;
END IF	

LET _fecha = "26/03/2008";

IF MONTH(_fecha) < 10 THEN
	LET _periodo = YEAR(_fecha) || '-0' || MONTH(_fecha);
ELSE
	LET _periodo = YEAR(_fecha) || '-' || MONTH(_fecha);
END IF

INSERT INTO cobremae
VALUES(
a_no_remesa,
"001",
"003",
'005',
_null,
"CORRECCION PAGOS MAL APLICADOS",
'C',
_fecha,
0,
3,
0.00,
0,
_periodo,
"demetrio",
_fecha,
"demetrio",
_fecha,
1
);

let _renglon = 0;

foreach
 select no_remesa,
        renglon
   into _no_remesa_error,
        _renglon_error
   from cobredet
  where doc_remesa in ("0208-00018-03", "0208-00070-03", "0203-00154-03", "1805-00106-03", "0207-00845-03", "1800-00280-01", "1805-00043-03", "1805-00044-03", "0104-00074-03", "0498-00005-99", "1808-00011-03", "1808-00012-03", "1808-00013-03")
    and tipo_mov   = "P"
    and prima_neta < impuesto
  order by fecha

	let _renglon = _renglon + 1;

	-- Detalle del Pago
		
	select *
	  from cobredet
	 where no_remesa = _no_remesa_error
	   and renglon   = _renglon_error
	  into temp tmp_cobredet;
	  
	  update tmp_cobredet
	     set no_remesa    = a_no_remesa,
		     renglon      = _renglon,
		     tipo_mov     = "N",
		     monto        = monto * -1,
		     prima_neta   = prima_neta * -1,
		     impuesto     = impuesto * -1,
		     fecha        = _fecha,
		     periodo      = _periodo,
		     actualizado  = 0,
		     sac_asientos = 0;

	insert into cobredet
	select *
	  from tmp_cobredet;

	drop table tmp_cobredet;
	
	-- Detalle del corredor
	
	select *
	  from cobreagt
	 where no_remesa = _no_remesa_error
	   and renglon   = _renglon_error
	  into temp tmp_cobreagt;
	   
	  update tmp_cobreagt
	     set no_remesa  = a_no_remesa,
		     renglon    = _renglon,
		     monto_calc = monto_calc * -1,
		     monto_man  = monto_man * -1;

	insert into cobreagt
	select *
	  from tmp_cobreagt;

	drop table tmp_cobreagt;
	
end foreach

end 

--rollback work;
commit work;

return 0, "Actualizacion Exitosa", a_no_remesa;

end procedure
