-- Procedimiento que Graba el Asiento de la Factura

-- Creado    : 25/10/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 25/10/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_par250;		

CREATE PROCEDURE "informix".sp_par250(
a_no_poliza	CHAR(10), 
a_no_endoso CHAr(5), 
a_cuenta    CHAR(25), 
a_debito    DEC(16,2),
a_credito   DEC(16,2),
a_cod_aux	char(5),
a_tipo_comp	smallint
)

define _cantidad	smallint;

select count(*)
  into _cantidad
  from endasiau
 WHERE no_poliza    = a_no_poliza
   AND no_endoso    = a_no_endoso
   AND cuenta 	    = a_cuenta
   and cod_auxiliar = a_cod_aux
   and tipo_comp	= a_tipo_comp;

if _cantidad = 0 then

	INSERT INTO endasiau(
	no_poliza,
	no_endoso,
	cuenta,
	cod_auxiliar,
	debito,
	credito,
	tipo_comp
	)
	VALUES(
	a_no_poliza,
	a_no_endoso,
	a_cuenta,
	a_cod_aux,
	a_debito,
	a_credito,
	a_tipo_comp
	);

else


	UPDATE endasiau
	   SET debito 	    = debito  + a_debito,
	       credito 	    = credito + a_credito
	 WHERE no_poliza    = a_no_poliza
	   AND no_endoso    = a_no_endoso
	   AND cuenta 	    = a_cuenta
	   and cod_auxiliar = a_cod_aux
	   and tipo_comp	= a_tipo_comp;

end if

select count(*)
  into _cantidad
  from cglauxiliar
 where aux_cuenta  = a_cuenta
   and aux_tercero = a_cod_aux;

if _cantidad = 0 then

	insert into cglauxiliar(
	aux_cuenta,
	aux_tercero,
	aux_pctreten,
	aux_saldoret,
	aux_corriente,
	aux_30dias,
	aux_60dias,
	aux_90dias,
	aux_120dias,
	aux_150dias,
	aux_ultimatrx,
	aux_ultimodcmto,
	aux_observacion
	)
	values(
	a_cuenta,
	a_cod_aux,
	0.00,
	0.00,
	0.00,
	0.00,
	0.00,
	0.00,
	0.00,
	0.00,
	"",
	"",
	""
	);

end if

END PROCEDURE;
