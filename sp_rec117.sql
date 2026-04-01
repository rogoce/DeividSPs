
drop procedure sp_rec117;

create procedure "informix".sp_rec117(a_no_reclamo char(10))

delete from recrccob where no_reclamo = a_no_reclamo;
delete from recnotas where no_reclamo = a_no_reclamo;
delete from recrcde2 where no_reclamo = a_no_reclamo;
delete from recrcmae where no_reclamo = a_no_reclamo;

end procedure