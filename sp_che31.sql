
DROP PROCEDURE sp_che31;

CREATE PROCEDURE "informix".sp_che31()

drop table chqcomis;

CREATE TABLE chqcomis(
cod_agente		CHAR(15),
no_poliza		CHAR(10),
no_recibo		CHAR(10),
fecha			DATE,
monto           DEC(16,2),
prima           DEC(16,2),
porc_partic		DEC(5,2),
porc_comis		DEC(5,2),
comision		DEC(16,2),
nombre			CHAR(50),
no_documento    CHAR(20),
monto_vida      DEC(16,2),
monto_danos     DEC(16,2),
monto_fianza    DEC(16,2),
no_licencia     CHAR(10),
seleccionado    SMALLINT DEFAULT 0
);

create index idx_chqcomis_1 on chqcomis (cod_agente, seleccionado); 

alter table chqcomis lock mode (row);

end procedure