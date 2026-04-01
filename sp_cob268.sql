-- Proceso Generar el informe de Morosidad por Corredor	para los Ramos Personales
-- Creado por :     Roman Gordon	08/02/2011
-- SIS v.2.0 - DEIVID, S.A.


Drop Procedure sp_cob267;

Create Procedure "informix".sp_cob267(a_cod_agente char(5), a_compania char(3), a_sucursal char(3))
Returning char(20),		 -- 1_no_documento,			
		  													
			
Define _nombre_agente		char(100);
Define _nombre_cliente		char(100);
SET ISOLATION TO DIRTY READ;

--set debug file to "sp_cob265.trc";
--trace on;
