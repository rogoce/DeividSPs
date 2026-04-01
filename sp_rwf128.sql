-- Procedimiento que aumenta la reserva	para terceros

-- Creado    : 18/06/2014 - Autor: Amado Perez M. 

--drop procedure sp_rwf120;
drop procedure sp_rwf128;

create procedure sp_rwf128(a_no_reclamo char(10), a_incidente integer) 
  returning integer,
            char(50),
            char(10),
            char(10);

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
define _no_unidad           char(5);
define _reserva_actual      decimal(16,2);
define _cod_ramo            char(3);
define _variacion           dec(16,2);
define _cod_tipotran        char(3);
define _cod_cobertura_rec   char(5);
define _user_added          char(8);
define _cerrar_rec          smallint;
define _monto               dec(16,2);
define _deducible           varchar(50);
define _deducible_d 		dec(16,2);

define _cod_evento          char(3);
define _suma_asegurada   	decimal(16,2);
define _tipo                smallint;
define a_opcion      		smallint;
define _hoy                 DATETIME HOUR TO FRACTION(5);
define _cant                smallint;
define _tipo_dano           smallint;

set isolation to dirty read;

if a_incidente = 178304 then
  set debug file to "sp_rwf128.trc";
  trace on;
end if

begin work;

begin 
on exception set _error, _error_isam, _error_desc
	rollback work;
	return _error, _error_desc, "", "";
end exception

let _reserva_actual = 0; 


select cod_compania,
       cod_sucursal,
	   numrecla,
	   cod_asegurado,
	   no_poliza,
	   no_unidad,
	   cod_evento,
	   suma_asegurada,
	   tipo_dano
  into _cod_compania,
       _cod_sucursal,
	   _numrecla,
	   _cod_cliente,
	   _no_poliza,
	   _no_unidad,
	   _cod_evento,
	   _suma_asegurada,
	   _tipo_dano
  from recrcmae
 where no_reclamo = a_no_reclamo;

select user_added
  into _user_added
  from recterce
 where no_reclamo =  a_no_reclamo
   and no_incidente = a_incidente;

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = _no_poliza;

--IF _cod_ramo = '023' THEN
--	LET _cod_ramo = '002'; 
--END IF

let _aplicacion = "REC";

SELECT version
  INTO _version
  FROM insapli
 WHERE aplicacion = _aplicacion;

SELECT valor_parametro
  INTO _valor_parametro
  FROM inspaag
 WHERE codigo_compania  = _cod_compania
   AND aplicacion       = _aplicacion
   AND version          = _version
   AND codigo_parametro	= 'fecha_recl_default';

IF TRIM(_valor_parametro) = '1' THEN   --Toma la fecha del servidor

	LET _fecha_no_server = CURRENT;				

ELSE								   --Toma la fecha de un parametro establecido por computo.

	SELECT valor_parametro			  
      INTO _valor_parametro2
	  FROM inspaag
	 WHERE codigo_compania  = _cod_compania
	   AND aplicacion       = _aplicacion
	   AND version          = _version
	   AND codigo_parametro	= 'fecha_recl_valor';

	LET _fecha_no_server = DATE(_valor_parametro2);				

END IF

IF MONTH(_fecha_no_server) < 10 THEN
	LET _periodo_rec = YEAR(_fecha_no_server) || "-0" || MONTH(_fecha_no_server);
ELSE
	LET _periodo_rec = YEAR(_fecha_no_server) || "-" || MONTH(_fecha_no_server);
END IF

foreach
	select reserva
	  into _monto
	  from recrepro
	 where cod_ramo = '020'
	   and periodo  <= _periodo_rec
	   and tipo_dano = _tipo_dano
    order by periodo desc
	exit foreach;
end foreach

let _cod_cobertura = null;

select e.cod_cobertura, e.deducible 
  into _cod_cobertura, _deducible
  from emipocob e, prdcober p
 where e.cod_cobertura = p.cod_cobertura
   and e.no_poliza = _no_poliza
   and e.no_unidad = _no_unidad
   and p.cod_ramo = _cod_ramo
   and p.nombre like '%PROPIEDAD AJENA%';
 --  and e.prima_anual <> 0.00;

if _cod_cobertura is null then
    foreach
		select e.cod_cobertura, e.deducible  
		  into _cod_cobertura, _deducible
		  from endedcob e, prdcober p
		 where e.cod_cobertura = p.cod_cobertura
		   and e.no_poliza = _no_poliza
		   and e.no_unidad = _no_unidad
		   and p.cod_ramo = _cod_ramo
		   and p.nombre like '%PROPIEDAD AJENA%'
		exit foreach;
	end foreach
end if 

if _cod_cobertura is null or trim(_cod_cobertura) = "" then
	rollback work;
	return 1, "El codigo de cobertura esta nulo", "", "";
end if

if _deducible is null or trim(_deducible) = "" then
	let _deducible = "0.00";
end if


let _deducible = REPLACE(trim(_deducible),",","");
let _deducible = REPLACE(trim(_deducible),"P/E","");
let _deducible = REPLACE(trim(_deducible),"P / E","");
let _deducible = REPLACE(trim(_deducible),"..","");
let _deducible_d = _deducible; 

let _reserva_cob = 0.00;

select sum(a.variacion)
  into _reserva_cob
  from rectrcob a, rectrmae b
 where a.no_tranrec = b.no_tranrec
   and b.no_reclamo = a_no_reclamo
   and a.cod_cobertura = _cod_cobertura
   and b.actualizado = 1;

if _reserva_cob is null then
	let _reserva_cob = 0.00;
end if

if _reserva_cob >= _monto then
	rollback work;
	return 0, "No necesita transaccion de aumento", "", "";
end if

-- Nueva reserva inicial 
let _monto = _monto - _reserva_cob; 

LET _cod_tipotran = '002';
LET _variacion = _monto;


-- Asignacion del Numero Interno y Externo de Transacciones

LET _no_tran_char = sp_sis12(_cod_compania, _cod_sucursal, a_no_reclamo);
LET _no_tranrec_char = sp_sis13(_cod_compania, _aplicacion, _version, 'par_tran_genera');

INSERT INTO rectrmae(
no_tranrec,
cod_compania,
cod_sucursal,
no_reclamo,
cod_cliente,
cod_tipotran,
cod_tipopago,
no_requis,
no_remesa,
renglon,
numrecla,
fecha,
impreso,
transaccion,
perd_total,
cerrar_rec,
no_impresion,
periodo,
pagado,
monto,
variacion,
generar_cheque,
actualizado,
user_added
)
VALUES(
_no_tranrec_char,
_cod_compania,
_cod_sucursal,
a_no_reclamo,
_cod_cliente,
_cod_tipotran,
null,
null,
null,
null,
_numrecla,
_fecha_no_server,
0,
_no_tran_char,
0,
0,
0,
_periodo_rec,
0,
_monto,
_variacion,
0,
1,
_user_added
);

-- Insercion de las Coberturas (Transacciones)

INSERT INTO rectrcob(
no_tranrec,
cod_cobertura,
monto,
variacion
)
VALUES(
_no_tranrec_char,
_cod_cobertura,
_monto,
_variacion
);

--Insertando en la descripcion

INSERT INTO rectrde2(
no_tranrec,
renglon,
desc_transaccion
)
VALUES(
_no_tranrec_char,
1,
"AUMENTO DE RESERVA AUTOMATICO DEL TERCERO"
);


-- Actualizar Reclamos
let _cant = 0;

select count(*)
  into _cant
  from recrccob
 where no_reclamo = a_no_reclamo
   and cod_cobertura = _cod_cobertura;

if _cant = 0 then
	Insert into recrccob (no_reclamo, cod_cobertura, reserva_inicial, reserva_actual, deducible)
	              values (a_no_reclamo, _cod_cobertura, 0, _monto, _deducible_d);
else
    update recrccob 
       set reserva_actual = reserva_actual + _monto	
     where no_reclamo = a_no_reclamo
       and cod_cobertura = _cod_cobertura;
end if   

update recrcmae
   set estatus_reclamo = "A"
 where no_reclamo = a_no_reclamo;            	

-- Insertando RECNOTAS

LET _hoy = CURRENT;
LET _hoy = _hoy + 1 units second;
CALL sp_rwf104(a_no_reclamo,_hoy,"AUMENTO DE RESERVA AUTOMATICO DEL TERCERO",_user_added) returning _error, _error_desc;
IF _error <> 0 THEN
	rollback work;
	RETURN  _error, _error_desc, "", "";
END IF
  

end
commit work;

return 0, "Actualizacion Exitosa", _no_tran_char, _no_tranrec_char;

end procedure