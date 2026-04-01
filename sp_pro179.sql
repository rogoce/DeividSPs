-- Procedimiento que genera informacion de Polizas de Auto Cobertura completa Vs RC
-- 
-- Creado     : 14/03/2007 - Autor: Marquelda Valdelamar
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sac25;		

CREATE PROCEDURE "informix".sp_sac25(a_periodo1 char(7), a_periodo2 char(7), a_cuenta char(25))
