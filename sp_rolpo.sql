-- Procedimiento que Crea el Historico de Polizas
-- 
-- Creado    : 06/11/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 06/11/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_rolpo;		

CREATE PROCEDURE "informix".sp_rolpo(a_no_poliza CHAR(10))
RETURNING INTEGER;

DEFINE _cod_compania CHAR(3);
DEFINE _cod_sucursal CHAR(3);
DEFINE _no_documento CHAR(20);
DEFINE _no_factura   CHAR(20);
DEFINE _no_doc_orig  CHAR(20);

DEFINE _no_endoso    CHAR(5);
DEFINE _cod_endomov  CHAR(3);
DEFINE _null         CHAR(1);
DEFINE _nueva_renov  CHAR(1);

LET _null      = NULL;
LET _no_endoso = '0';


-- Eliminar Registros

DELETE FROM endcobde WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcobre WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedcob WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcuend WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmotra WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmoaut WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedde2 WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedacr WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endunide WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endunire WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endeduni WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedimp WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedrec WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endeddes WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endasien WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmoage WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmoase WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcamco WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedde1 WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedmae WHERE no_poliza = a_no_poliza AND no_endoso = _no_endoso;

RETURN 0;

END PROCEDURE;
