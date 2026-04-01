-- Procedimiento que Busca el banco y chequera dado el ramo de excepcion

-- Creado    : 19/05/2006 - Autor: Armando Moreno.

-- SIS v.2.0 - uo_recl_validar_m (ue_icon) - DEIVID, S.A.

DROP PROCEDURE sp_rec183;

CREATE PROCEDURE "informix".sp_rec183(a_compania CHAR(3), a_cliente	char(10), a_banco CHAR(3), a_chequera CHAR(3))
returning char(3),char(3),CHAR(1);

define _tipo_pago		smallint;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _tipo_requis     char(1);

SET ISOLATION TO DIRTY READ;

let _cod_banco    = a_banco;
let _cod_chequera = a_chequera;
let _tipo_requis  = "C";

-- En Deivid Gestion todo se paga por cheque
-- Se cambia para que se pueda pagar por ACH -- Amado Perez 16-03-2020
--*****************
select tipo_pago  
  into _tipo_pago
  from cliclien
 where cod_cliente = a_cliente;

IF _tipo_pago = 1 THEN -- Pago por ACH	--> Se mantiene la chequera de salud 06 y se pidio autorizacion al banco para que acepte ACH
	SELECT che_banco_ach
	  INTO _cod_banco
	  FROM parparam
	 WHERE cod_compania = a_compania;

 	LET _tipo_requis = "A";

END IF

--**************
Return _cod_banco,_cod_chequera,_tipo_requis;

END PROCEDURE
