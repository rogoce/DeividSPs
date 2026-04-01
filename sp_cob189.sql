-- Procedure que morosidad normal vs especial
 													   
drop procedure sp_cob189;

create procedure sp_cob189()

{
create table pxcr0510(
no_documento	char(20),
saldo_nor		dec(16,2),
saldo_esp		dec(16,2)
);

alter table pxcr0510 lock mode (row);
}

delete from pxcr0510;

insert into pxcr0510
select v_doc_poliza,
       sum(v_saldo),
	   0.00
  from pxcn0510
 group by v_doc_poliza;

insert into pxcr0510
select poliza,
       0.00,
	   sum(saldo)
  from pxce0510
 group by poliza;

update pxcr0510
   set saldo_nor = 0.00
 where saldo_nor is null;

update pxcr0510
   set saldo_esp = 0.00
 where saldo_esp is null;

end procedure