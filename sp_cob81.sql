-- Verificacion de Saldos por Ano
-- 
-- Creado    : 22/01/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 22/01/2002 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob81;

CREATE PROCEDURE "informix".sp_cob81(
a_periodo	char(7),
a_cuadran	char(1)
)
returning char(20),
		  char(10),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);

define a_compania	char(3);
define a_sucursal	char(3);
define _dia			smallint;
define _mes			smallint;
define _ano			smallint;
define _fecha1		date;
define _fecha2		date;

--set debug file to "sp_cob81.trc";
--trace on;

let a_compania = "001";
let a_sucursal = "001";

let _mes = a_periodo[6,7];
let _ano = a_periodo[1,4];

If _mes = 1  or 
   _mes = 3  or	
   _mes = 5  or	
   _mes = 7  or	
   _mes = 8  or	
   _mes = 10 or	
   _mes = 12 then
    let _dia = 31;
elif _mes = 2 then
	let _dia = 28;
else
	let _dia = 30;
end if
   						
let _fecha2 = MDY(_mes, _dia, _ano);

if _mes = 1 then
	let _mes = 12;
	let _ano = _ano - 1;
else
	let _mes = _mes - 1;
end if

If _mes = 1  or 
   _mes = 3  or	
   _mes = 5  or	
   _mes = 7  or	
   _mes = 8  or	
   _mes = 10 or	
   _mes = 12 then
   let _dia = 31;
elif _mes = 2 then
   let _dia = 28;
else
   let _dia = 30;
end if

let _fecha1 = MDY(_mes, _dia, _ano);

SET ISOLATION TO DIRTY READ;

--drop table tmp_comp;

create temp table tmp_comp(
no_poliza		char(10),
saldo1			dec(16,2) default 0,
monto			dec(16,2) default 0,
saldo2			dec(16,2) default 0
) with no log;

create temp table tmp_poliza(
no_documento	char(20),
saldo1			dec(16,2) default 0,
monto			dec(16,2) default 0,
saldo2			dec(16,2) default 0
) with no log;

--{
call sp_cob05(a_compania, a_sucursal, _fecha1);

insert into tmp_comp(
no_poliza,
saldo1
)
select
no_poliza,
saldo
from tmp_moros;

drop table tmp_moros;
  
call sp_cob05(a_compania, a_sucursal, _fecha2);

insert into tmp_comp(
no_poliza,
saldo2
)
select
no_poliza,
saldo
from tmp_moros;

drop table tmp_moros;
--}

begin

define a_periodo1		char(7);
define a_periodo2		char(7);

DEFINE _no_poliza        CHAR(10); 
DEFINE _prima_bruta      DEC(16,2);
DEFINE _cod_ramo         CHAR(3);  
DEFINE _cod_tipoprod     CHAR(3);  
DEFINE _tipo_produccion  SMALLINT; 
DEFINE _no_requis 		 CHAR(10);

DEFINE _fecha_anulado1	 DATE;
DEFINE _fecha_anulado2	 DATE;

let a_periodo1 = "2002-01";
let a_periodo2 = "2002-01";

-- Facturas

FOREACH
 SELECT prima_bruta,
		no_poliza
   INTO _prima_bruta,
		_no_poliza
   FROM endedmae
  WHERE cod_compania = "001"
    AND periodo     >= a_periodo1
    AND periodo     <= a_periodo2
	AND actualizado  = 1
	AND prima_bruta  <> 0 

	SELECT cod_ramo,
	       cod_tipoprod
	  INTO _cod_ramo,
	       _cod_tipoprod
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;
	 
	 IF _tipo_produccion = 4 THEN
	 	CONTINUE FOREACH;
	 END IF 	

	insert into tmp_comp(
	no_poliza,
	monto
	)
	values(
	_no_poliza,
	_prima_bruta
	);

END FOREACH	

-- Recibos

FOREACH
 SELECT	monto,
        no_poliza
   INTO	_prima_bruta,
        _no_poliza
   FROM	cobredet
  WHERE cod_compania = "001"
	AND actualizado = 1
	AND tipo_mov   IN ('P', 'N')
    AND periodo    >= a_periodo1
    AND periodo    <= a_periodo2
	AND monto      <> 0

	SELECT cod_ramo,
	       cod_tipoprod
	  INTO _cod_ramo,
	       _cod_tipoprod
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;
	 
	 IF _tipo_produccion = 4 THEN
	 	CONTINUE FOREACH;
	 END IF 	

	LET _prima_bruta = _prima_bruta * -1;

	insert into tmp_comp(
	no_poliza,
	monto
	)
	values(
	_no_poliza,
	_prima_bruta
	);

END FOREACH

-- Cheques Pagados

FOREACH
 SELECT no_requis
   INTO _no_requis
   FROM chqchmae m
  WHERE m.pagado        = 1
    AND m.periodo      >= a_periodo1
    AND m.periodo      <= a_periodo2
	AND m.origen_cheque = "6"

   FOREACH	
	SELECT no_poliza,
		   monto
	  INTO _no_poliza,
	       _prima_bruta
	  FROM chqchpol
	 WHERE no_requis = _no_requis

		SELECT cod_ramo,
		       cod_tipoprod
		  INTO _cod_ramo,
		       _cod_tipoprod
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		SELECT tipo_produccion
		  INTO _tipo_produccion
		  FROM emitipro
		 WHERE cod_tipoprod = _cod_tipoprod;
		 
		 IF _tipo_produccion = 4 THEN
		 	CONTINUE FOREACH;
		 END IF 	

		insert into tmp_comp(
		no_poliza,
		monto
		)
		values(
		_no_poliza,
		_prima_bruta
		);

	END FOREACH

END FOREACH

-- Cheques Anulados

LET _fecha_anulado1 = MDY(a_periodo1[6,7], 1, a_periodo1[1,4]);

IF a_periodo2[6,7] = 12 THEN
	LET _fecha_anulado2 = MDY(1, 1, a_periodo2[1,4] + 1);
ELSE
	LET _fecha_anulado2 = MDY(a_periodo2[6,7] + 1, 1, a_periodo2[1,4]);
END IF

FOREACH
 SELECT no_requis
   INTO _no_requis
   FROM chqchmae m
  WHERE m.pagado        = 1
    AND m.fecha_anulado >= _fecha_anulado1
    AND m.fecha_anulado < _fecha_anulado2
	AND m.origen_cheque = "6"
	AND m.anulado       = 1

   FOREACH	
	SELECT no_poliza,
		   monto
	  INTO _no_poliza,
	       _prima_bruta
	  FROM chqchpol
	 WHERE no_requis = _no_requis

		SELECT cod_ramo,
		       cod_tipoprod
		  INTO _cod_ramo,
		       _cod_tipoprod
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		SELECT tipo_produccion
		  INTO _tipo_produccion
		  FROM emitipro
		 WHERE cod_tipoprod = _cod_tipoprod;
		 
		 IF _tipo_produccion = 4 THEN
		 	CONTINUE FOREACH;
		 END IF 	

		LET _prima_bruta = _prima_bruta * -1;

		insert into tmp_comp(
		no_poliza,
		monto
		)
		values(
		_no_poliza,
		_prima_bruta
		);

	END FOREACH

END FOREACH

end

begin

DEFINE _no_poliza 		CHAR(10); 
define _saldo1     		dec(16,2);
define _monto     		dec(16,2);
define _saldo2     		dec(16,2);
define _no_documento	char(20);

foreach
 select no_poliza,
		sum(saldo1),
		sum(monto),
		sum(saldo2)
   into _no_poliza,
		_saldo1,
		_monto,
		_saldo2
   from tmp_comp
  group by no_poliza	

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	insert into tmp_poliza
	values(
	_no_documento,
	_saldo1,
	_monto,
	_saldo2
	);

end foreach

foreach
 select no_documento,
		sum(saldo1),
		sum(monto),
		sum(saldo2)
   into _no_documento,
		_saldo1,
		_monto,
		_saldo2
   from tmp_poliza
  group by no_documento

	if a_cuadran = "0" Then

		if (_saldo1 + _monto) <> _saldo2 then

			return _no_documento,
			       "",
				   _saldo1,
			   	   _monto,
				   _saldo2
				   with resume;

		end if
	else

		return _no_documento,
		       "",
			   _saldo1,
		   	   _monto,
			   _saldo2
			   with resume;

	end if

end foreach

end
   	
drop table tmp_comp;
drop table tmp_poliza;

end procedure