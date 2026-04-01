-- Pase de Borderaux a Estado de Cuenta
-- execute procedure sp_pr995("2009-2010",2,"03/03/2010")
-- Creado por Henry Giron
-- Fecha 13/11/2009
--sp_pr127("001","001",_per_1,_per_3,"*","*","*","*","001,003,006,008,010,011,012,013,014,021,022;","*","*","2012,2011,2010,2009,2008;")

--drop procedure sp_pr995a;
create procedure "informix".sp_pr995a(a_anio char(9),a_trimestre smallint,a_fecha date,a_anio2 char(9), a_trimestre2 smallint)
returning integer,char(50);

DEFINE _anio_reas						Char(9);
DEFINE _trim_reas						Smallint;
DEFINE _borderaux						CHAR(2); 
DEFINE _existe							Smallint;
DEFINE _contrato						CHAR(2);
DEFINE _desc_contrato				 	CHAR(50);

DEFINE s_renglon            			SMALLINT;
DEFINE s_debito,s_credito   			DECIMAL(16,2);
DEFINE s_p_partic						DECIMAL(16,2);
DEFINE s_cod_clase						VARCHAR(3);
DEFINE c_cod_ramo						VARCHAR(10);
DEFINE s_cod_contrato					VARCHAR(5);
DEFINE s_des_cod_clase      			VARCHAR(255);

DEFINE s_existe  						SMALLINT;
DEFINE _eexiste							SMALLINT;
DEFINE _eno_remesa					    CHAR(10);

DEFINE _ecod_compania					CHAR(3);
DEFINE _ecod_sucursal					CHAR(3);
DEFINE _etipo							CHAR(2);
DEFINE _efecha							date;
DEFINE _ecod_coasegur					CHAR(3);
DEFINE _ecod_contrato					CHAR(2);
DEFINE _eperiodo						CHAR(7);
DEFINE _ecomprobante					CHAR(8);
DEFINE _econcepto						CHAR(3);
DEFINE _emoneda							CHAR(2);
DEFINE _eccosto							CHAR(3);
DEFINE _edescrip						CHAR(100);
DEFINE _emonto							decimal (16,2);
DEFINE _edebito							decimal (16,2);
DEFINE _ecredito						decimal (16,2);
DEFINE _eusuario						CHAR(15);
DEFINE _eactualizado					SMALLINT;
DEFINE _esac_asientos					SMALLINT;
DEFINE _ecod_banco						CHAR(3);
DEFINE _dno_remesa						SMALLINT;
DEFINE _dcod_compania					CHAR(3);
DEFINE _dcod_sucursal					CHAR(3);
DEFINE _dtipo							CHAR(2);
DEFINE _drenglon						smallint;
DEFINE _dcod_coasegur					CHAR(3);
DEFINE _dcod_ramo						CHAR(3);
DEFINE _dcod_contrato					CHAR(2);
DEFINE _dno_recibo						CHAR(10);
DEFINE _dfecha							DATE;
DEFINE _dcuenta							CHAR(12);
DEFINE _dccosto							CHAR(3);
DEFINE _ddebito							decimal(16,2);
DEFINE _dcredito						decimal(16,2);
DEFINE _dactualizado					smallint;
DEFINE s_cod_coasegur 					CHAR(3);
DEFINE _per_1,_per_3					CHAR(7);
define _error							integer;
define _error_desc						char(50);

begin
SET ISOLATION TO DIRTY READ;  

LET _existe = 0;
	

--BACKUP DE LAS TABLAS DE ESTADO DE CTA.

insert into reaestct1bk 
select * from reaestct1
 where ano       = a_anio
   and trimestre = a_trimestre;

insert into reaestct1bk 
select * from reaestct1
 where ano       = a_anio2
   and trimestre = a_trimestre2;

insert into reaestct2bk 
select * from reaestct2
 where ano       = a_anio
   and trimestre = a_trimestre;

insert into reaestct2bk 
select * from reaestct2
 where ano       = a_anio2
   and trimestre = a_trimestre2;


return 0,"PROCESO REALIZADO CON EXITO";
end 

end procedure;		