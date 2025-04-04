# Banking System Project Documentation

## Design Experience and Conclusions

Our journey through this banking system project has been both challenging and rewarding. Here's what we learned along the way:

### The Database Journey

#### Early Design Phase (Assignment 1 - 3)
The foundation of our project started with entity-relationship modeling, which was one of the most enjoyable phases:
- Drawing our first ER diagram felt like architecting a building
- Identifying entities was straightforward (Customer, Account, Transaction)
- The tricky part was figuring out relationships:
  - Should a customer have multiple accounts? (Yes - 1:M relationship)
  - How do we handle different account types? (Solved with specialization)
  - What's the best way to connect transactions to accounts?

The schema design phase taught us:
- Converting entities to tables isn't just drawing boxes
- Careful consideration of attribute types (VARCHAR vs TEXT, INT vs DECIMAL)
- The importance of primary key selection
- How foreign keys maintain referential integrity
- That many-to-many relationships need bridge tables

This early design work proved invaluable - a good blueprint makes construction easier!

#### Starting Out (Assignment 4)
We began with the basics - creating tables and establishing relationships. This is where we really got our hands dirty with SQL, learning:
- How to design tables that make sense for a banking system
- The importance of choosing the right data types (like DECIMAL for money!)
- Setting up relationships with FOREIGN KEY constraints
- The joy of seeing our first successful JOIN operations


#### Getting Advanced (Assignment 5)
This is where SQL got really interesting. We learned:
- Complex JOIN operations (LEFT, INNER, multiple joins)
- Window functions for analyzing transaction patterns
- Subqueries and how they can be nested
- Creating views to simplify complex queries
- Using GROUP BY with HAVING for sophisticated data analysis

The most satisfying moment was when we got our first complex query actually working - seeing transaction summaries grouped by customer with running totals without errors.

#### The 3NF Challenge (Assignment 7)
Normalization to Third Normal Form taught us:
- How to spot and eliminate transitive dependencies
- Breaking down the Card table to remove redundant customer data
- Why storing calculated fields is usually a bad idea
- The art of balancing normalization with practical needs

We actually saw our queries become simpler after normalization - that was a real "ohh I get it" moment.

#### BCNF - The Final Form (Assignment 8)
The journey to Boyce-Codd Normal Form showed us:
- How to identify and fix functional dependencies
- Why the Employee-Position-Department relationship needed restructuring
- The importance of candidate keys
- When to stop normalizing (didn't know this was a thing)

### The GUI Adventure
Building the interface was our biggest challenge. Working with tkinter taught us:
- How to connect Python code to our MySQL database
- The importance of error handling (we break everything we touch)
- Session management and security considerations
- That a good database design makes GUI development easier

### What We're Most Proud Of
1. Our database design - it started simple but grew into a robust, normalized system
2. The complex queries we mastered - from simple SELECTs to window functions and complex JOINs
3. Successfully implementing CRUD operations with proper error handling
4. Learning to think about data integrity at every step

### Biggest Challenges and Learnings
1. **SQL Complexity**: Starting with basic queries and progressing to complex joins and subqueries was challenging, but seeing them work was rewarding
2. **Normalization**: Understanding when to normalize and when to stop - sometimes practicality beats perfect normalization
3. **GUI Development**: Connecting our beautiful database to a functional interface was harder than expected
4. **Error Handling**: Learning to anticipate and handle all possible user inputs and database states

### Looking Back
What started as a simple database project turned into a comprehensive learning experience. While the GUI development pushed us out of our comfort zone, the database design and SQL work was genuinely enjoyable. We learned that good database design isn't just about following rules - it's about making something that works well in the real world.

The most valuable lesson for us was: start with a solid foundation (good database design), and everything else becomes easier. 
