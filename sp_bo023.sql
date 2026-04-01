drop procedure sp_bo023;

create procedure sp_bo023(a_ano char(4))
returning char(50),
          integer,
		  integer;

define _cantidad1	integer;
define _cantidad2	integer;

{
create table cobmoros_old(
no_documento         	char(20),
periodo              	char(7),
saldo                	decimal(16,2),
por_vencer           	decimal(16,2),
exigible             	decimal(16,2),
corriente            	decimal(16,2),
dias_30              	decimal(16,2),
dias_60              	decimal(16,2),
dias_90              	decimal(16,2),
no_poliza            	char(10),
saldo_neto           	decimal(16,2),
por_vencer_neto      	decimal(16,2),
exigible_neto        	decimal(16,2),
corriente_neto       	decimal(16,2),
dias_30_neto         	decimal(16,2),
dias_60_neto         	decimal(16,2),
dias_90_neto         	decimal(16,2),
mayor_30             	decimal(16,2),
mayor_60             	decimal(16,2),
mayor_30_neto        	decimal(16,2),
mayor_60_neto        	decimal(16,2),
cobros_por_vencer    	decimal(16,2),
cobros_exigible      	decimal(16,2),
cobros_corriente     	decimal(16,2),
cobros_30            	decimal(16,2),
cobros_60            	decimal(16,2),
cobros_90            	decimal(16,2),
cobros_total         	decimal(16,2),
cobros_total_neto    	decimal(16,2),
cobros_por_vencer_neto  decimal(16,2),
cobros_exigible_neto   	decimal(16,2),
cobros_corriente_neto   decimal(16,2),
cobros_30_neto       	decimal(16,2),
cobros_60_neto       	decimal(16,2),
cobros_90_neto       	decimal(16,2),
saldos_impuesto      	decimal(16,2),
saldos_neto_impuesto   	decimal(16,2),
fecha_ult_pago       	date,
monto_ult_pago       	decimal(16,2)
);
}

set isolation to dirty read;

insert into cobmoros_old
select * from cobmoros
 where periodo[1,4] = a_ano;

select count(*)
  into _cantidad1
  from cobmoros
 where periodo[1,4] = a_ano;

select count(*)
  into _cantidad2
  from cobmoros_old
 where periodo[1,4] = a_ano;

return "Cantidada Procesada ", _cantidad1, _cantidad2; 

end procedure